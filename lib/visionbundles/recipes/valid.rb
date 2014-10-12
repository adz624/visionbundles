require 'net/ssh/simple'

Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
    desc "validate settings"
    task :valid, on_error: :continue do; end
  end

  namespace :valid do
    desc 'check if server connection ok'
    task :remote_server_connection, on_error: :continue do
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
      if scm == :git
        find_servers.map { |server|
          Thread.new {
            host = server.to_s
            # TODO: have to change a way to check response with git ls-remote (branch may named `denied`)
            if capture("echo `git ls-remote #{repository} 2>&1`", hosts: host).strip.include?('denied')
              valid_faild "Server: #{host} cannot access git repo: #{repository}"
            else
              valid_pass "Server: #{host} have git repo permission access."
            end
          }
        }.each { |task| task.join }
      else
        valid_skip "skip valid if remote servers have git pull permission."
      end
    end
  end
  after 'deploy:valid', 'valid:remote_server_connection', 'valid:git_deploy_key_checker'
end