Capistrano::Configuration.instance(:must_exist).load do
  
  set_default(:database_template, 'database.production.yml')

  namespace :db do
    desc 'copy production database config from local'
    task :copy_production_config, roles: [:app, :web] do
      info '[Template] Copy Database Template'
      copy_production_from_local(database_template, 'database.yml')
    end

    desc "setup database configuration for application server"
    task :setup, roles: [:app, :web] do
      # It will check if shared database config exists will not over write
      mkdir("#{shared_path}/config")
      database_setting_path = "#{shared_path}/config/database.yml"
      run_if_file_not_exists?(database_setting_path, "cp #{template_database_path} #{database_setting_path}")
    end
    after 'deploy:setup', 'db:copy_production_config', 'db:setup'

    desc "setup database symlink for every time deploy"
    task :symlink_config, roles: [:app, :web] do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end

    after "deploy:finalize_update", "db:symlink_config"

    desc "remove database config file"
    task :remove_config, roles: [:app, :web] do
      run "rm #{shared_path}/config/database.yml"
    end

    desc 'reset database config file from local'
    task :reset_config do
      copy_production_config
      overwrite_config!('database.yml')
    end
  end
end
