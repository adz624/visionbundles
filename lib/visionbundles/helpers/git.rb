module Visionbundles
  module Helpers
    module Git
      def file_in_source_control?(file_path)
        `git ls-files #{file_path}` != ''
      end
    end
  end
end
include Visionbundles::Helpers::Git
