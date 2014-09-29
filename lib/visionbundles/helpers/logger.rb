require 'colorize'
module Visionbundles
  module Helpers
    module Logger
      def info(message)
        puts "#{current_server} -> #{message}".to_s.colorize(:light_cyan)
      end

      def warn(message)
        puts "#{current_server} -> #{message}".to_s.colorize(:red)
      end
    end
  end
end
include Visionbundles::Helpers::Logger