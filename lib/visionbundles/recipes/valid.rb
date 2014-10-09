require 'net/ssh/simple'

Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
    desc "validate settings"
    task :valid, on_error: :continue do
      # Capistrano initial checker
      not_found_files = (capistrano_files = %w(./Capfile ./config/deploy.rb)).map { |file|
        file unless File.exists?(file)
      }.compact

      if not_found_files.empty?
        valid_pass "Capistrano file exists: #{capistrano_files.join(', ')}"
      else
        valid_faild "Not found file #{not_found_files.join(', ')}, you should run `capify .` to initial capistrano setting."
      end
    end
  end

  namespace :valid do
    desc 'check if server connection ok'
    task :server_connection, on_error: :continue do
      # Servers connection
      servers = {}
      find_servers.each do |server|
        connection = Net::SSH::Simple.async do
          begin
            ssh server.to_s, 'echo "test_connection"', user: user
          rescue; end
        end
        servers[server.to_s] = connection.value
      end

      servers.each do |host, data|
        if servers[host].nil?
          valid_faild "Server: #{host} connection faild. please check firewall, ssh service and make sure public is in right place on your server."
        else
          valid_pass "Server: #{host} connection successful."
        end
      end
    end

    desc "Check remote servers have permission to access git server"
    task :git_deploy_key_checker, on_error: :continue do
      find_servers.each do |server|
        host = server.to_s
        response = capture("git ls-remote #{repository}", hosts: host).strip
        if response.include?('Permission denied (publickey).')
          valid_faild "Server: #{host} cannot access git repo: #{repository}"
        else
          valid_pass "Server: #{host} have git repo permission access."
        end
      end
    end
  end
  after 'deploy:valid', 'valid:server_connection', 'valid:git_deploy_key_checker'
end