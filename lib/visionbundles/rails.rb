module Visionbundles
  class Engine < Rails::Engine
    generators do
      require "generators/install_generator"
    end
  end
end