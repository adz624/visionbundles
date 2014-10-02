require 'bundler/capistrano'
require 'rvm/capistrano'
require 'visionbundles'

# RVM Settings
set :rvm_ruby_string, '2.1.0'
set :rvm_type, :user
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

# Recipes Included
# Source: https://github.com/afunction/visionbundles/blob/master/lib/visionbundles/recipes
include_recipes :nginx, :puma, :db, :dev, :fast_assets
# :fast_assets recipes will compile assets locally then upload assets files to servers
# So if you use :fast_assets you have to make sure your local repository commit id same as you deployed.

# Nginx
# Please change `nginx_app_servers` to your app servers ip, and make sure your web server have permission to 
# connect to the ips that you set.
# Source: https://github.com/afunction/visionbundles/blob/master/lib/visionbundles/recipes/nginx.rb
set :nginx_vhost_domain, 'www.domain.com' # your domain that to nginx.
set :nginx_upstream_via_sock_file, false
set :nginx_app_servers, [ '192.168.1.100:9290', '192.168.1.101:9290' ] # upstream will point to app server.


# Puma
# This setting will bind puma service to each ip address (include public ip)
# for security you may using firewall to make sure people cannot connect to your app server directly.
# Source: https://github.com/afunction/visionbundles/blob/master/lib/visionbundles/recipes/puma.rb
set :puma_bind_for, :tcp
set :puma_bind_to, '0.0.0.0'
set :puma_bind_port, '9290'
set :puma_thread_min, 32
set :puma_thread_max, 32
set :puma_workers, 3

# Role Settings
# The db roles mean the app server which you specify the run the db operation like `db:migrate`.
server '11.22.33.44', :web
server '22.33.44.55', :app
server '33.44.55.66', :app, :db, primary: true

# Capistrano Base Setting
set :application, 'your_project_name'
set :user, 'rails'
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :rails_env, :production

# Git Settings
set :scm, :git
set :repository, "git@github.com:username/#{application}.git" # your git source, and make sure your server have premission to access your git server
set :branch, :master # the branch you want to deploy

# Extra settings
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after 'deploy', 'deploy:cleanup' # keep only the last 5 releases
