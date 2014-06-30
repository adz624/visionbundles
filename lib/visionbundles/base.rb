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
end