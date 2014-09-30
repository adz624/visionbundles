require 'yaml' # STEP ONE, REQUIRE YAML!
module Visionbundles
  module Helpers
    module Configuration
      def config_from_yaml(file_path, env)
        config = YAML::load_file("./#{file_path}")[env.to_s]
        config ||= {config: {}, servers: []}
        config['config'].each do |key, value|
          send(:set, key, value)
        end
        config['servers'].each do |server|
          roles = server['roles'].is_a?(Array) ? server['roles'].map(&:to_sym) : [ server['roles'].to_sym ]
          if server['opts'].is_a?(Hash)
            options = Hash[server['opts'].map { |k, y| [k.to_sym, y] }]
            roles.push(options)
          end
          send(:server, server['host'], *roles)
        end
      end
    end
  end
end
include Visionbundles::Helpers::Configuration