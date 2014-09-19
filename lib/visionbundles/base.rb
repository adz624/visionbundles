require 'erb'
require 'colorize'
if defined?(Capistrano)
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

  def include_recipes(*recipes)
    recipes.each do |recipe|
      require "#{File.dirname(__FILE__)}/recipes/#{recipe}.rb"
    end
  end

  def set_default(name, *args, &block)
    set(name, *args, &block) unless exists?(name)
  end

  def current_server
    capture("echo $CAPISTRANO:HOST$").strip
  end

  def info(message)
    puts "#{current_server} -> #{message}".to_s.colorize(:light_cyan)
  end

  def warn(message)
    puts "#{current_server} -> #{message}".to_s.colorize(:red)
  end

  def copy_production_from_local(local_file, remote_file)
    mkdir("#{shared_path}/template")
    remote_full_path = "#{shared_path}/template/#{remote_file}"
    put File.read("config/#{local_file}"), remote_full_path

    remote_full_path
  end

  def overwrite_config!(config_file)
    origin_config_path = production_config(config_file)
    replace_config_path = "#{shared_path}/config/#{config_file}"
    run "cp #{origin_config_path} #{replace_config_path}"
  end

  def production_config(config_file)
    "#{shared_path}/template/#{config_file}"
  end

  def have_primary_database?
    roles[:app].each do |server|
      if server.options[:primary]
        return true
      end
    end
    return false
  end
end