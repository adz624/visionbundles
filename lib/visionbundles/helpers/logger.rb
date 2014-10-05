require 'colorize'
module Visionbundles
  module Helpers
    module Logger
      def info(message)
        puts "#{current_server} -> #{message}".colorize(:light_cyan)
      end

      def warn(message)
        puts "#{current_server} -> #{message}".colorize(:red)
      end

      def valid_pass(topic)
        puts "\t[Pass] #{topic}".colorize(color: :green, background: :light_white).underline
      end

      def valid_faild(topic)
        puts "\t[Pass] #{topic}".colorize(color: :red, background: :light_white).underline
      end
    end
  end
end
include Visionbundles::Helpers::Logger