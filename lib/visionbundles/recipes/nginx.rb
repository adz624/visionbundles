Capistrano::Configuration.instance(:must_exist).load do
  set_default(:nginx_vhost_domain, '_')
  set_default(:nginx_app_timeout, nil)
  set_default(:nginx_upstream_via_sock_file, true)
  set_default(:nginx_app_servers) {
    nginx_upstream_via_sock_file ? "/tmp/#{application}.sock" : "127.0.0.1:9292"
  }

  namespace :nginx do
    desc "setup nginx vhost config"
    task :setup, roles: :web do
      info '[Nginx] Setup vhost configuration files ...'
      template "templates/nginx/nginx.conf.erb", "#{shared_path}/nginx", "vhost.conf"
      sudo "ln -nfs #{shared_path}/nginx/vhost.conf /etc/nginx/sites-enabled/#{application}"
    end
    after 'deploy:setup', 'nginx:setup'

    %w[start stop restart reload].each do |command|
      desc "#{command} nginx server"
      task command, roles: :web do
        sudo "service nginx #{command}"
      end
    end
  end
end