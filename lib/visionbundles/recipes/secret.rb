Capistrano::Configuration.instance(:must_exist).load do
  preconfig_files('secret_token.rb' => 'config/initializers/secret_token.rb')
end
