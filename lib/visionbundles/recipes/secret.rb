Capistrano::Configuration.instance(:must_exist).load do
  begin
    require 'rails'
    major, minor = Rails.gem_version.to_s.split(',').map(&:to_i)
    if major == 4 && [0, 1].include?(minor)
      source, desc = case minor
      when 0 then; ['secret_token.rb', 'config/initializers/secret_token.rb']
      when 1 then; ['secrets.yml', 'config/secrets.yml']
      end
      return preconfig_files(source => desc)
    end
  rescue; end
  raise 'Only support rails 4.1.x and 4.0.x'
end
