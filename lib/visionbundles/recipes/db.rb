Capistrano::Configuration.instance(:must_exist).load do
  preconfig_files('database.yml' => 'config/database.yml')

  # TODO:
  # => 1. change the recipes name to :mysql
  # => 2. check servers can access database?
end