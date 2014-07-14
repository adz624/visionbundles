Capistrano::Configuration.instance(:must_exist).load do
  namespace :secret do
    desc "Setup secret file"
    task :setup, roles: :app do
      mkdir("#{shared_path}/config")
      secret_file_path = "#{shared_path}/config/secret_token.rb"
      if remote_file_exists?(secret_file_path)
        warn '[SKIP] secret file exists already ...'
      else
        info '[Secret] Setup decret file in shared path...'
        put File.read("config/initializers/secret_token.example.rb"), secret_file_path
      end
    end
    after 'deploy:setup', 'secret:setup'

    desc "setup secret file symlink for every time deploy"
    task :symlink, roles: :app do
      run "ln -nfs #{shared_path}/config/secret_token.rb #{release_path}/config/initializers/secret_token.rb"
    end
    after "deploy:finalize_update", "secret:symlink"
  end
end
