Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
    desc "validate settings"
    task :valid do
      # Capistrano initial checker
      %w(Capfile config/deploy.rb).each do |file|
        unless File.exists?(file)
          valid_faild "Not found file #{file}, you should run `capify .` to initial capistrano setting."
        end
      end
      # Security:
      # => 1. rails app secret key
      # => 2. is preconfig folder in source control.

      # Remote:
      # => 1. check if deploy user setup already.
      # => 2. check database setup already.
      # => 3. check remote servers have permission to access git server
      # => 4. check local have permission to access remote servers
    end
  end
end
