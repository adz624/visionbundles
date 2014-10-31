namespace :assets do
  task :remote_assets_host => :environment do
    puts Rails.application.config.action_controller.asset_host
  end

  task :precompile_locally do
    ENV['asset_host'] = ENV['remote_assets_host']
    Rake::Task['environment'].invoke
    Rake::Task['assets:precompile'].invoke
  end
end