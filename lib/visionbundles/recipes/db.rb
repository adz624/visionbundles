Capistrano::Configuration.instance(:must_exist).load do
  namespace :db do
    desc "setup database configuration"
    task :setup, roles: :app do
      mkdir("#{shared_path}/config")
      database_setting_path = "#{shared_path}/config/database.yml"
      if remote_file_exists?(database_setting_path)
        puts '[SKIP] Database configuration exists already ...'.colorize(:red)
      else
        puts '[Shared] Setup database configuration files ...'.colorize(:light_cyan)
        put File.read("config/database.example.yml"), database_setting_path
      end
    end
    after 'deploy:setup', 'db:setup'

    desc "setup database symlink for every time deploy"
    task :symlink_config, roles: :app do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
    after "deploy:finalize_update", "db:symlink_config"
    before 'deploy:symlink', 'deploy:migrate'
  end
end
