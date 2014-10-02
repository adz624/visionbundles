require 'rails/generators'
module Visionbundles
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)
      argument :deploy_template, type: :string, default: "single"

      # check the argument deploy_template, should be single or mutiple
      def check
        unless %w(single multiple).include?(deploy_template)
          puts "You have to choice a template: single or multiple"
          puts "\trails g visionbundles:install single"
          puts "\trails g visionbundles:install mutiple"
          exit
        end
      end

      # copy the capistrano setting from template
      def copy_deploy_template
        copy_file "deploy_#{deploy_template}.rb", "config/deploy.rb"
      end

      # add gem for capistrano + rvm
      def add_capistrano_rvm
        unless File.readlines("Gemfile").grep(/rvm-capistrano/).any?
          gem_group :development do
            gem 'rvm-capistrano'
          end
        end
      end

      # copy exists database config to predefine folder
      def create_database_example_config
        if File.exists?('config/database.yml')
          copy_file "#{Rails.root}/config/database.example.yml", "preconfig/database.yml"
        else
          copy_file "database.yml", "preconfig/database.yml"
        end
      end
    end
  end
end