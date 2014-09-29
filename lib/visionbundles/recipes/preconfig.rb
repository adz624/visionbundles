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
  end
end