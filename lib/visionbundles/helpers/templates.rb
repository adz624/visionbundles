require 'erb'
module Visionbundles
  module Helpers
    module Templates
      def from_template(file)
        abs_path = File.join(File.dirname(__FILE__), file)
        template = File.read(abs_path)
        ERB.new(template).result(binding)
      end

      def template(erb_source, to_dir, filename)
        mkdir(to_dir)
        compiled_file = "#{to_dir}/#{filename}"
        put from_template(erb_source), compiled_file
      end
    end
  end
end
include Visionbundles::Helpers::Templates