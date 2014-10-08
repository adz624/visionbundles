require 'visionbundles/recipes/preconfig/helpers'

Capistrano::Configuration.instance(:must_exist).load do
  set_default(:preconfig_dir) { "./preconfig" }
  set_default(:preconfig_roles) { [:app, :web, :worker] }

  namespace :preconfig do
    desc "upload configuration file to shared path"
    task :upload_config, roles: lambda { preconfig_roles} do
      preconfig_files_list.each do |source, destination|
        info "[Preconfig] uploading preconfig/#{source}"
        upload_preconfig_file(source)
      end
    end
    after 'deploy:setup', 'preconfig:upload_config'

    task :symlink, roles: lambda { preconfig_roles} do
      preconfig_files_list.each do |source, destination|
        config_file_path = remote_preconfig_souece(source)
        info "[Preconfig] symlinking => #{destination}"
        run "ln -nfs #{config_file_path} #{release_path}/#{destination}"
      end
    end
    after "deploy:finalize_update", "preconfig:symlink"

    desc <<-DESC
      This task will check preconfig source file exists in local, and destination not in source control.
      deploy flow will use `ln` command to make a symlink those config file to release folder,
      however this command will not replace when file exists. so we should make sure those file exists in local
      and destination not in source control.
    DESC
    task :valid do
      unless File.exists?(preconfig_dir)
        valid_faild "Not found preconfig folder: #{preconfig_dir}"
      end

      local_preconfigurations = []
      destination_preconfigurations = []

      preconfig_files_list.each do |source, destination|
        local_file_path = "#{preconfig_dir}/#{source}"

        # Make sure precofig source file is exists in local.
        unless File.exists?(local_file_path)
          local_preconfigurations.push(local_file_path)
        end

        # Make sure preconfig destination is out of source control.
        if file_in_source_control?(destination)
          destination_preconfigurations.push(destination)
        end
      end

      if local_preconfigurations.empty?
        valid_pass "Preconfig source: #{preconfig_files_list.map(&:first).join(', ')}"
      else
        valid_faild "Not found preconfig files: #{local_preconfigurations.join(', ')}"
      end

      if destination_preconfigurations.empty?
        valid_pass "Preconfig destination: #{preconfig_files_list.map(&:last).join(', ')}"
      else
        valid_faild "Have to remove from source control files: #{destination_preconfigurations.join(', ')}"
      end
    end

    after 'deploy:valid', 'preconfig:valid'
  end
end