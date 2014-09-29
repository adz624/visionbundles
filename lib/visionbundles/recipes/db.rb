Capistrano::Configuration.instance(:must_exist).load do
  preconfig_files('database.yml' => 'config/database.yml')
end
