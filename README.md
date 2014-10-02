## Summary

This gem with basic deploy flow tasks for capistrano 2.15.5, you don't have to write deploy tasks yourself, just configuare it. And that includes recipes:

1. nginx
2. puma
3. preconfig (new feature)
4. db
5. secret
6. fast_assets 
7. dev

## Installation

in your `Gemfile`

```ruby
group :development do
  gem 'capistrano', '~> 2.15.5', require: false
  gem 'visionbundles', '~> 0.2.0'
  # gem 'visionbundles', github: 'afunction/visionbundles' # or use latest source
end
```

then run `bundle install`


## Wiki

* [Getting Started](https://github.com/afunction/visionbundles/wiki/Getting-Started)
* [Recipe - Nginx](https://github.com/afunction/visionbundles/wiki/%5BRecipe%5D-nginx)
* [Recipe - Puma](https://github.com/afunction/visionbundles/wiki/%5BRecipe%5D-puma)
* [Recipe - fast_assets (compile assets locally)](https://github.com/afunction/visionbundles/wiki/%5BRecipe%5D-fast_assets)
* [Recipe - preconfig](https://github.com/afunction/visionbundles/wiki/%5BRecipe%5D--preconfig)
* [Recipe - db, dev](https://github.com/afunction/visionbundles/wiki/%5BRecipe%5D-db,-dev)
* [Using yaml to protect and easy to switch your deploy.rb](https://github.com/afunction/visionbundles/wiki/Using-yaml-to-protect-and-easy-to-switch-your-deploy.rb)


## Other tools

[ubuntu-rails-app-installer](https://github.com/afunction/ubuntu-rails-app-installer) is a server tool for install basic rails production environment and this script write on `shellscript`, you can use it to install nginx, percona database, basic secure setting, firewall, rails deploy user ... etc.


## Contribution

Just send PR to me.

# Contact me

eddie [at] visionbundles [dot] com 


![Visionbundles Int'l Ltd.](http://www.visionbundles.com/assets/logo-927ee5bf7632c30e2642ddf03b607e42.png)