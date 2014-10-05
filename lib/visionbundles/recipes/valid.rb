Capistrano::Configuration.instance(:must_exist).load do
  namespace :visionbundles do
    desc "validate settings"
    task :valid do
      %w(setting db preconfig).each do |task|
        visionbundles.validation.send(task)
      end
    end

    namespace :validation do
      desc "capistrano setting"
      task :setting do
        %w(Capfile config/deploy.rb).each do |file|
          unless File.exists?(file)
            valid_faild "Not found file #{file}, you should run `capify .` to initial capistrano setting."
          end
        end
      end

      desc "config/database.yml"
      task :db do
        if file_in_source_control?('config/database.yml')
          valid_faild '"config/database.yml should not in source control, please remove and commit, then add line in .gitignore."'
        end
      end

      desc <<-DESC
      This task will check preconfig source file exists in local, and destination not in source control.
        deploy flow will use `ln` command to make a symlink those config file to release folder,
        however this command will not replace when file exists. so we should make sure those file exists in local
      and destination not in source control.
        DESC
      task :preconfig do
        unless File.exists?(preconfig_dir)
          valid_faild "Not found preconfig folder: #{preconfig_dir}"
        end

        local_preconfigurations = []
        remote_preconfigurations = []

        preconfig_files_list.each do |source, destination|
          local_file_path = "#{preconfig_dir}/#{source}"

          # Make sure precofig source file is exists in local.
          unless File.exists?(local_file_path)
            local_preconfigurations.push(local_file_path)
          end

          # Make sure preconfig destination is out of source control.
          if file_in_source_control?(destination)
            remote_preconfigurations.push(destination)
          end
        end

        unless local_preconfigurations.empty?
          valid_faild "Not found preconfig files: #{local_preconfigurations.join(', ')}"
        end

        unless remote_preconfigurations.empty?
          valid_faild "Have to remove from source control files: #{remote_preconfigurations.join(', ')}"
        end
      end
    end

    desc <<-DESC
    
    DESC
    task :security do
      # TODO:
      # => 1. rails app secret key
      # => 2. is preconfig folder in source control.
    end

    desc <<-DESC
    
    DESC
    task :remote do
      # TODO:
      # => 1. check if deploy user setup already.
      # => 2. check database setup already.
      # => 3. check remote servers have permission to access git server
      # => 4. check local have permission to access remote servers
    end
  end
end

def file_in_source_control?(file_path)
  `git ls-files #{file_path}` != ''
end