Capistrano::Configuration.instance(:must_exist).load do
  preconfig_files('database.yml' => 'config/database.yml')

  namespace :db do
    desc "config/database.yml"
    task :check do
      if file_in_source_control?('config/database.yml')
        valid_faild '"config/database.yml should not in source control, please remove and commit, then add line in .gitignore."'
      end
    end
  end
  after 'deploy:valid', 'db:check'
end