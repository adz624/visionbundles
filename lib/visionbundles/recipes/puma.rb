Capistrano::Configuration.instance(:must_exist).load do
  set_default(:puma_bind_for, 'sock_file') # sock_file / tcp
  set_default(:puma_bind_to, '0.0.0.0')
  set_default(:puma_bind_port, '9292')
  set_default(:puma_thread_min, 1)
  set_default(:puma_thread_max, 16)
  set_default(:puma_workers, 0)
  set_default(:puma_config_template) { "../templates/puma/config.erb" }
  set_default(:puma_preload_app) { true }

  namespace :puma do
    desc "Setup Puma Scripts"
    task :setup, roles: :app do
      info '[Puma] copying the config'
      template puma_config_template, "#{shared_path}/puma", "config.rb"
    end
    after 'deploy:setup', 'puma:setup'

    %w[start stop].each do |command|
      desc "#{command} puma server"
      task command, roles: :app do
        run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec pumactl -F #{shared_path}/puma/config.rb #{command}"
      end
    end
    desc "restart puma server"
    task "restart", roles: :app do
      %w(stop start).each do |command|
        run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec pumactl -F #{shared_path}/puma/config.rb #{command}"
      end
    end
  end
end