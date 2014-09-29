module Visionbundles::PreconfigFiles
  @@preconfig_files = {}

  def self.preconfig_files
    @@preconfig_files
  end

  def preconfig_files(src_to_dests)
    src_to_dests.each do |file, desc|
      Visionbundles::PreconfigFiles.preconfig_files[file] = desc
    end
  end

  def remote_preconfig_souece(file)
    "#{shared_path}/preconfig/#{file}"
  end

  def upload_preconfig_file(source)
    preconfig_path = "#{shared_path}/preconfig"
    mkdir(preconfig_path)
    put File.read("#{preconfig_dir}/#{source}"), "#{preconfig_path}/#{source}"
  end

  def preconfig_files_list
    Visionbundles::PreconfigFiles.preconfig_files
  end
end
include Visionbundles::PreconfigFiles