namespace :assets do
  task :remote_assets_version => :environment do
    puts Rails.application.assets.version
  end

  task :precompile_locally => :environment do
    Rails.application.assets.version = ENV['remote_assets_version']
    Rake::Task['assets:precompile'].invoke
  end
end