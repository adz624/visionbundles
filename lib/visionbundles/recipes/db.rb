Capistrano::Configuration.instance(:must_exist).load do
  
  set_default(:database_template, 'database.production.yml')

  namespace :db do
    desc "setup database configuration for application server"
    task "setup", roles: [:app, :web] do
      # It will overwrite template database
      mkdir("#{shared_path}/template")
      template_database_path = "#{shared_path}/template/database.yml"
      put File.read("config/#{database_template}"), template_database_path
      info '[Template] Copy Database Template'

      # It will check if shared database config exists will not over write
      mkdir("#{shared_path}/config")
      database_setting_path = "#{shared_path}/config/database.yml"

      run_if_file_not_exists?(database_setting_path, "cp #{template_database_path} #{database_setting_path}")
    end
    after 'deploy:setup', 'db:setup'

    desc "setup database symlink for every time deploy"
    task :symlink_config, roles: [:app, :web] do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end

    after "deploy:finalize_update", "db:symlink_config"

    desc "remove database config file"
    task :remove_config, roles: [:app, :web] do
      run "rm #{shared_path}/config/database.yml"
    end
  end
end
