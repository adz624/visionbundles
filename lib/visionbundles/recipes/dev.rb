Capistrano::Configuration.instance(:must_exist).load do
  set_default(:dev_sure_danger_command) {
    Capistrano::CLI.password_prompt "Are you sure run danger command in #{current_server} if yes type Y"
  }

  namespace :dev do
    desc "dev:build task"
    task :build, roles: :app, except: {no_release: true} do
      if dev_sure_danger_command == 'Y'
        ["tmp:clear", "log:clear", "db:drop", "db:create", "db:migrate", "db:seed"].each do |rake_command|
          run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake #{rake_command}"
        end
      end
    end
  end
end