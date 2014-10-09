require "asset_sync"
module AssetSync
  class Config
    attr_accessor :manifest_path, :assets_prefix, :public_path

    def log_silently
      false
    end

    def yml_exists?
      false
    end
  end
end