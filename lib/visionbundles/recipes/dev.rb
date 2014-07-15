Capistrano::Configuration.instance(:must_exist).load do
  set_default(:dev_sure_danger_command) {
    Capistrano::CLI.password_prompt "Are you sure run danger command in #{current_server} (Y/N)"
  }

  namespace :dev do
    desc "Run a task on a remote server."  
    task :invode, roles: :app do 
      command = "cd #{current_path}; /usr/bin/env bundle exec rake #{ENV['task']} RAILS_ENV=#{rails_env}"
      info "Are you sure to run:"
      info command
      run command if dev_sure_danger_command
    end

    desc "dev:build task"
    task :build, roles: :app do
      unless have_primary_database?
        return warn "Not Found Primary Database"
      end
      if dev_sure_danger_command == 'Y'
        ["tmp:clear", "log:clear", "db:drop", "db:create", "db:migrate", "db:seed"].each do |rake_command|
          run "cd #{current_path}; bundle exec rake #{rake_command} RAILS_ENV=#{rails_env}"
        end
      end
    end
  end
end