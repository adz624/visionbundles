require 'rails/generators'
module Visionbundles
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)
      argument :deploy_template, type: :string, default: "single"

      def git_init
        run 'git init; git add .; git commit -m "init project"' unless File.exists?('.git')
        run 'git reset .'
      end

      def copy_deploy_template
        copy_file "Capfile", "Capfile"
        copy_file "deploy.rb", "config/deploy.rb"
        run 'git add Capfile; git add config/deploy.rb; git commit -m "Init visionbundle deploy setting."'
      end

      def add_capistrano_rvm
        gem_group :development do
          gem 'rvm-capistrano'
        end
        run 'bundle install'
        run 'git add Gemfile*; git commit -m "add gem capistrano-rvm and bundle install."'
      end

      def create_database_example_config
        if File.exists?('config/database.yml')
          copy_file "#{Rails.root}/config/database.yml", "config/database.example.yml"
          copy_file "#{Rails.root}/config/database.example.yml", "preconfig/database.yml"
        else
          copy_file "database.yml", "preconfig/database.yml"
          copy_file "database.yml", "config/database.example.yml"
        end
        run 'git add config/database.example.yml'
        run 'git commit -m "create a database config template!"'
      end

      def out_of_database_config_from_source_control
        if `git ls-files config/database.yml` != ''
          run 'git rm config/database.yml'
          run 'git commit -m "remove database configuration out of source control!"'
        end

        append_file ".gitignore" do
          <<-eos
/preconfig/ # production preconfig folder
/config/database.yml" # should not in source control
          eos
        end
        run 'git add .gitignore'
        run 'git commit -m "git ignore files: preconfig, database.yml"'
      end
    end
  end
end
