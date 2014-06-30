## Summary

This gem have basic deploy flow tasks for capistrano 2.x, that include templates (nginx / puma / sidekiq). you don't have to write deploy tasks yourself, just configuare it.

## Installation


in your `Gemfile`

```ruby
group :development do
  gem 'capistrano', '~> 2.15.5'
  gem 'visionbundles'
end
```

then run `bundle install`


## deploy.rb

```ruby
# deploy.rb

# add this line on top
require 'visionbundles'

# setup recipes what your need (nginx, puma, db, dev)
include_recipes :nginx, :puma, :db, :dev
```

once you include recipes like `db` `nginx` `puma` it will hook tasks in your deploy flow, you just need run `cap deploy:setup` at first, it will setup all you need. but you have to config your recipes setting.


## Recipes configurations

### nginx

```ruby
# Nginx (role: :web)
set :nginx_vhost_domain, 'your.domain' # default is _, means all
set :nginx_upstream_via_sock_file, false, # if your app server bind a unix socket file, you need setup to true

set :nginx_app_servers, ['127.0.0.1:9290'] # your app server ip with port
```

`cap nginx:start`
`cap nginx:stop`
`cap nginx:restart`


### puma (role: :app)

```ruby
# Puma
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


### db (role: :app)

If you include this recipe, when you run `cap deploy:setup` will copy database config file from your project `config/database.example.yml` to server site shared path.

If database config file exists in remote server, will not replace. so if you change nginx / puma configuration and you want to reset again, you can run `cap deploy:setup` again.

### sidekiq (role: :workers)

`cap sidekiq:start`
`cap sidekiq:stop`
`cap sidekiq:restart`

P.S this task is not test.


### dev (role: :app)

This task provide a command `cap dev:build`, it will invoke tasks `tmp:clear` `log:clear` `db:drop` `db:create` `db:migrate` `db:seed` on remote server.

when you run this command, you have to type `Y` to confirm that you really want to run it.


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





