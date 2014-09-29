module Visionbundles::PreconfigFiles
  @@preconfig_files = {}
  
  def self.preconfig_files
    @@preconfig_files
  end

  module Helpers
    def preconfig_files(src_to_dests)
      src_to_dests.each do |file, desc|
        Visionbundles::PreconfigFiles.preconfig_files[file] = desc
      end
    end

    def remote_preconfig_souece(file)
      "#{shared_path}/preconfig/#{file}"
    end

    def upload_preconfig_file(source)
      preconfig_path = "#{shared_path}/preconfig"
      mkdir(preconfig_path)
      put File.read("#{preconfig_dir}/#{source}"), "#{preconfig_path}/#{source}"
    end

    def preconfig_files_list
      Visionbundles::PreconfigFiles.preconfig_files
    end
  end
end

include Visionbundles::PreconfigFiles::Helpers

Capistrano::Configuration.instance(:must_exist).load do
  set_default :preconfig_dir, "./preconfig"

  namespace :preconfig do
    desc "upload configuration file"
    task :upload_config, roles: [:app, :web] do
      preconfig_files_list.each do |source, destination|
        info "[Preconfig] uploading preconfig/#{source}"
        upload_preconfig_file(source)
      end
    end
    after 'deploy:setup', 'preconfig:upload_config'

    task :symlink, roles: [:app, :web] do
      preconfig_files_list.each do |source, destination|
        config_file_path = remote_preconfig_souece(source)
        info "[Preconfig] symlinking => #{destination}"
        run "ln -nfs #{config_file_path} #{release_path}/#{destination}"
      end
    end
    after "deploy:finalize_update", "preconfig:symlink"
  end
end
