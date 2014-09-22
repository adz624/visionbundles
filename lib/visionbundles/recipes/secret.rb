Capistrano::Configuration.instance(:must_exist).load do

  set_default(:secret_template, 'initializers/secret_token.production.rb')

  namespace :secret do
    desc 'copy production secret file from local'
    task :copy_production_config, roles: :app do
      info '[Template] Copy Secret Template'
      copy_production_from_local(secret_template, 'secret_token.rb')
    end

    desc "Setup secret file"
    task :setup, roles: :app do
      mkdir("#{shared_path}/config")
      secret_file_path = "#{shared_path}/config/secret_token.rb"
      template_secret_path = production_config('secret_token.rb')
      run_if_file_not_exists?(secret_file_path, "cp #{template_secret_path} #{secret_file_path}")
    end
    after 'deploy:setup', 'secret:copy_production_config', 'secret:setup'

    desc "setup secret file symlink for every time deploy"
    task :symlink, roles: :app do
      run "ln -nfs #{shared_path}/config/secret_token.rb #{release_path}/config/initializers/secret_token.rb"
    end
    after "deploy:finalize_update", "secret:symlink"

    desc "remove secret config file"
    task :remove_config, roles: [:app, :web] do
      run "rm #{shared_path}/config/secret_token.rb"
    end

    desc 'reset secret config file from local'
    task :reset_config do
      copy_production_config
      overwrite_config!('secret_token.rb')
    end
  end
end
