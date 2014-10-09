require 'yaml'
module Visionbundles
  module Helpers
    module Configuration
      def load_config_from(file_path, env)
        config = YAML::load_file("./#{file_path}.yml")[env.to_s]
        setup_configs(config['config'] || {})
        setup_servers(config['servers'] || [])
        setup_preconfig(config['preconfig' || {}])
      end

      private

      def setup_configs(configs)
        configs.each do |key, value|
          send(:set, key, value)
        end
      end

      def setup_servers(servers)
        servers.each do |server|
          roles = server['roles'].is_a?(Array) ? server['roles'].map(&:to_sym) : [ server['roles'].to_sym ]
          if server['opts'].is_a?(Hash)
            options = Hash[server['opts'].map { |k, y| [k.to_sym, y] }]
            roles.push(options)
          end
          send(:server, server['host'], *roles)
        end
      end

      def setup_preconfig(preconfig)
        set :preconfig_dir, preconfig['root'] if preconfig['root'].present?
        preconfig_mapper = Hash[(preconfig['list'] || []).map { |list|
          [list['src'], list['dest']]
        }]
        preconfig_files Hash[preconfig_mapper] if preconfig_mapper.present?
      end
    end
  end
end
include Visionbundles::Helpers::Configuration
