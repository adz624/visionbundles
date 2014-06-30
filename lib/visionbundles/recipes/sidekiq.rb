Capistrano::Configuration.instance(:must_exist).load do
  namespace :sidekiq do
    %w[start stop restart killall].each do |command|
      desc "#{command} sidekiq"
      task command, roles: :workers, except: {no_release: true} do
        run "cd #{current_path}/scripts/ && RAILS_ENV=#{rails_env} ./workers.sh #{command}"
      end
    end
  end
end