module Visionbundles
  module Helpers
    module Recipes
      def include_recipes(*recipes)
        recipes.each do |recipe|
          require "visionbundles/recipes/#{recipe}.rb"
        end
      end

      def set_default(name, *args, &block)
        set(name, *args, &block) unless exists?(name)
      end
    end
  end
end
include Visionbundles::Helpers::Recipes
include_recipes 'preconfig'