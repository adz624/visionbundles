module Visionbundles
  module Helpers
    module Servers
      def remote_file_exists?(path)
        results = []

        invoke_command("if [ -f '#{path}' ]; then echo -n 'true'; fi") do |ch, stream, out|
          results << (out == 'true')
        end

        !results.empty?
      end

      def run_if_file_exists?(path, command)
        run "if [ -f '#{path}' ]; then #{command}; fi"
      end

      def run_if_file_not_exists?(path, command)
        run "if [ ! -f '#{path}' ]; then #{command}; fi"
      end

      def mkdir(remote_path)
        run "mkdir -p #{remote_path}"
      end

      def current_server
        capture("echo $CAPISTRANO:HOST$").strip
      end
    end
  end
end
include Visionbundles::Helpers::Servers