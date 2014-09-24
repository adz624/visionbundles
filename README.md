## Summary

This gem with basic deploy flow tasks for capistrano 2.15.5, you don't have to write deploy tasks yourself, just configuare it. And that includes recipes:

1. nginx
2. puma
3. db
4. secret
5. fast_assets 
6. dev

## Installation

in your `Gemfile`

```ruby
group :development do
  gem 'capistrano', '~> 2.15.5'
  gem 'visionbundles'
  # or use latest source
  # gem 'visionbundles', github: 'afunction/visionbundles'
end
```

then run `bundle install`


## deploy.rb

```ruby
# Add this line on top
require 'visionbundles'

# Setup recipes what you need (include option nginx, puma, db, dev, fast_assets, secret)
include_recipes :nginx, :puma, :db, :dev
```

Once you include recipes like `db` `nginx` `puma` ... etc, it will hook tasks in your deploy flow, and you need to run `cap deploy:setup` at first time, it will setup all you need. but you have to config your recipes setting before.


## Recipe configurations

### nginx (role: :web)

```ruby
set :nginx_vhost_domain, 'your.domain' # default is _, means all
set :nginx_upstream_via_sock_file, false, # if your app server bind a unix socket file, you need setup to true

set :nginx_app_servers, ['127.0.0.1:9290'] # your app server ip with port
```

`cap nginx:start`
`cap nginx:stop`
`cap nginx:restart`

Source: https://github.com/afunction/visionbundles/blob/master/lib/visionbundles/recipes/nginx.rb


### puma (role: :app)

If you have multiple app server, you should setup `puma_bind_to` to `0.0.0.0`, and use other way to avoid directly connection to your app server form internet.

```ruby
set :puma_bind_for, :tcp # default is 'sock_file'
set :puma_bind_to, '127.0.0.1' # default is '0.0.0.0'
set :puma_bind_port, '9290' # default is 9292
set :puma_thread_min, 32
set :puma_thread_max, 32
set :puma_workers, 3
```

`cap puma:start`
`cap puma:stop`
`cap puma:restart`

Source: https://github.com/afunction/visionbundles/blob/master/lib/visionbundles/recipes/puma.rb

### fast_assets (locally)

If you have multiple app servers, or separate servers between app and web roles, or your assets on CDN, you may concern which server is resiponsible to compile assets and upload to servers.


This task will use least resource to compile assets and upload to remote server. it combine [Gem - AssetSync](https://github.com/rumblelabs/asset_sync) and compile assets locally instead of capistrano precompile task. 


*Without CDN*

You don't have to configure it, just add `fast_assets` recipe in your `deploy.rb`, it will compile assets locally, and upload `manifest file` to servers of app role and `assets files` to servers of web role.


*With CDN*

After include `fast_assets`recipe, you have to config your CDN access token, it will use [asset_sync](https://github.com/rumblelabs/asset_sync) to upload your assets to cloud, the example below using AWS S3:

```ruby
# CDN
set :cdn, {
  fog_provider: 'AWS',
  fog_directory: 'your_bucket_name',
  aws_access_key_id: 'your aws id', # create from IAM
  aws_secret_access_key: 'your aws secret token',
  fog_region: 'ap-northeast-1' # bucket region
}
```

Once you choose upload assets to CDN, deploy task will NOT upload asset files to your web server, because web dose not need it. For more details about CDN configuration, please visit: https://github.com/rumblelabs/asset_sync

Source: https://github.com/afunction/visionbundles/blob/master/lib/visionbundles/recipes/fast_assets.rb

### db (role: :app)

To avoid setting up db configuration manually, setup task will copy `config/database.production.yml` to your servers with `roles: :app`, and you can create the file with REAL production db configuration, and list the file to `.gitignore` to avoid sensitive data in your source control.


*cap db:reset_config*

The setup task will not overwide db config file if exists in remote server, but i also can use `cap db:reset_config` to replace your remote db config from local.

Source: https://github.com/afunction/visionbundles/blob/master/lib/visionbundles/recipes/db.rb

### Secret (role: :app)

Setup task will copy `initializers/secret_token.production.rb` to your servers which roles is app, like db recipes, you should create the file, and list in `.gitignore`.

*cap secret:reset_config*

Just like `db:reset_config` functionality.

Source: https://github.com/afunction/visionbundles/blob/master/lib/visionbundles/recipes/secret.rb

### dev (role: :app)

This task provide a command `cap dev:build`, it will invoke tasks `tmp:clear` `log:clear` `db:drop` `db:create` `db:migrate` `db:seed` on the server (same server which runs db:migrate).

This command will show a prompt box to confirm that you really want to do it.

Source: https://github.com/afunction/visionbundles/blob/master/lib/visionbundles/recipes/dev.rb


## Setup each environment config via yaml

You may think server architecture details should not in source control, or often update to different website in same project. you can use yaml easy to switch configuration. below is the example:


* deploy.rb *

```ruby
config_from_yaml 'deploy/config.yml', :my_testing_production
```

* deploy/config.yml *

```yaml
# Nginx
my_testing_production:
  servers:
    - host: '1.1.1.1'
      roles: 
        - 'web'
        - 'app'
        - 'db'
      opts:
        primary: yes
    - host: '2.2.2.2'
      roles: 'app'
  config:
    nginx_vhost_domain: 'my.domain.com'
    nginx_upstream_via_sock_file: no
    nginx_app_servers:
      - 192.168.1.3:9290
      - 192.168.1.4:9290
    # Puma
    puma_bind_for: 'tcp'
    puma_bind_port: '9290'
    puma_thread_min: 32
    puma_thread_max: 32
    puma_workers: 3
    cdn:
      fog_provider: 'AWS'
      fog_directory: ''
      aws_access_key_id: ''
      aws_secret_access_key: ''
      fog_region: 'ap-northeast-1'

```


### Full setting example

in `Capfile`

```ruby
load 'deploy'
load 'deploy/assets'
load 'config/deploy'
```

in `deploy.rb`

```ruby
require 'bundler/capistrano'
require 'rvm/capistrano'
require 'visionbundles'

# RVM Settings
set :rvm_ruby_string, '2.1.0'
set :rvm_type, :user
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

# Recipes Settings
include_recipes :nginx, :puma, :db, :dev

# Nginx
set :nginx_vhost_domain, '111.222.33.44'
set :nginx_upstream_via_sock_file, false
set :nginx_app_servers, ['127.0.0.1:9290']

# Puma
set :puma_bind_for, :tcp
set :puma_bind_to, '127.0.0.1'
set :puma_bind_port, '9290'
set :puma_thread_min, 32
set :puma_thread_max, 32
set :puma_workers, 3

# Role Settings
server '11.222.33.44', :web, :app, :db, primary: true

# Capistrano Base Setting
set :application, 'my-project-name'
set :user, 'rails'
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :rails_env, 'test'

# Git Settings
set :scm, :git
set :repository, "git@github.com:username/#{application}.git"
set :branch, 'develop'

# Others
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# Deploy Flow
after 'deploy', 'deploy:cleanup' # keep only the last 5 releases
```


## Other tools

[ubuntu-rails-app-installer](https://github.com/afunction/ubuntu-rails-app-installer) is a server tool for install basic rails production environment and this script write on `shellscript`, you can use it to install nginx, percona database, basic secure setting, firewall, rails deploy user ... etc.


## Contribution

Just send PR to me.


