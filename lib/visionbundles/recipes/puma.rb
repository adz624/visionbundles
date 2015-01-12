Capistrano::Configuration.instance(:must_exist).load do
  set_default(:puma_bind_for, 'sock_file') # sock_file / tcp
  set_default(:puma_bind_to, '0.0.0.0')
  set_default(:puma_bind_port, '9292')
  set_default(:puma_thread_min, 1)
  set_default(:puma_thread_max, 16)
  set_default(:puma_workers, 0)
  set_default(:puma_config_template) { "../templates/puma/config.erb" }
  set_default(:service_template) { "../templates/puma/service.erb" }
  set_default(:puma_preload_app) { false }
  set_default(:puma_prune_bundler) { false }
  set_default(:puma_worker_timeout) { nil }
  set_default(:puma_on_boot_connection_to_activerecord) { nil }
  set_default(:puma_reload_gem_when_restart) { true }

  namespace :puma do
    desc "Setup Puma Scripts"
    task :setup, roles: :app do
      # Copy configuration template to remote server
      info '[Puma] copying the config'
      template puma_config_template, "#{shared_path}/puma", "config.rb"

      # Copy service launcher to remote server "init.d/"
      template service_template, "#{shared_path}/puma", "service"
      service_remote_path = "#{shared_path}/puma/service"
      run "chmod +x #{service_remote_path}"
      sudo "rm -rf /etc/init.d/#{application}"
      sudo "ln -s #{service_remote_path} /etc/init.d/#{application}"

      # Setup app as a daemon
      sudo "update-rc.d #{application} defaults"
    end
    after 'deploy:setup', 'puma:setup'

    desc "start puma"
    task :start, roles: :app do
      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec puma -C #{shared_path}/puma/config.rb start"
    end

    %w[stop restart stats status phased-restart].each do |command|
      desc "#{command} puma server"
      task command, roles: :app do
        run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec pumactl -S #{shared_path}/pids/puma.state #{command}"
      end
    end
  end
end