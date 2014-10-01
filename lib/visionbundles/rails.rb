module Visionbundles
  class Engine < Rails::Engine
    generators do
      require "generators/config/config_generator"
    end
  end
end