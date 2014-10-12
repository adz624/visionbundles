Capistrano::Configuration.instance(:must_exist).load do
  require 'active_record'

  preconfig_files('database.yml' => 'config/database.yml')

  namespace :db do
    desc 'check if each servers can authenticate and connect to database'
    task :valid do
      db = YAML::load_file("./#{preconfig_dir}/database.yml")[rails_env.to_s]

      find_servers.map.with_index { |server, num|
        Thread.new {
          host = server.to_s
          port = Net::SSH::Gateway.new(host, user).open('127.0.0.1', 3306, 3307 + num)
          begin
            ActiveRecord::Base.establish_connection(db.merge(host: '127.0.0.1', port: port)).connection
            valid_pass "Server: #{host} database authenticate and connection successful."
          rescue Exception => e
            valid_faild "Server: #{host} cannot connect to database: #{db['host']}, please check the database.yml or database firewall."
          end  
        }
      }.each { |task| task.join }
    end
  end
  after 'deploy:valid', 'db:valid'
end