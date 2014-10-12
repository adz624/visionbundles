require 'visionbundles/asset_sync'

Capistrano::Configuration.instance(:must_exist).load do
  set_default(:precompile_env)   { rails_env }
  set_default(:precompile_cmd)   { "RAILS_ENV=#{precompile_env.to_s.shellescape} #{asset_env} #{rake} assets:precompile" }
  set_default(:cleanexpired_cmd) { "RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} #{rake} assets:clean_expired" }
  set_default(:rsync_cmd) { "rsync -av" }

  set_default(:assets_dir) { "public/assets" }

  set_default(:cdn) { nil }

  namespace :deploy do
    namespace :assets do

      desc "remove manifest file from shared path"
      task :remove_manifest do
        run "rm -rf #{shared_path}/#{shared_assets_prefix}/manifest*.json"
      end

      desc "cleanup local compiled assets"
      task :cleanup, on_no_matching_servers: :continue  do
        run_locally "rm -rf #{assets_dir}"
      end

      desc "Precompile assets locally"
      task :precompile, only: { primary: true }, on_no_matching_servers: :continue do
        run_locally "#{precompile_cmd}"
      end

      desc "Sync manifest on app servers"
      task :sync_manifest_to_app_servers, only: { primary: true }, on_no_matching_servers: :continue do
        local_manifest_path = run_locally("ls #{assets_dir}/manifest*")
        local_manifest_path.strip!
        # Only sync manifest to app server
        find_servers(roles: :app, except: { no_release: true }).each do |server|
          server_with_user = "#{user}@#{server}"
          run_locally "#{rsync_cmd} #{local_manifest_path} #{server_with_user}:#{shared_path}/assets/#{File.basename(local_manifest_path)}"
          run_locally "#{rsync_cmd} #{local_manifest_path} #{server_with_user}:#{release_path}/assets_manifest#{File.extname(local_manifest_path)}"
        end
      end

      desc "Sync assets to CDN or remote app server"
      task :sync_assets_files, only: { primary: true }, on_no_matching_servers: :continue do
        if cdn.nil?
          # If not using CDN, web should have asset files
          find_servers(roles: :web, except: { no_release: true }).each do |server|
            server_with_user = "#{user}@#{server}"
            run_locally "#{rsync_cmd} ./#{assets_dir}/ #{server_with_user}:#{release_path}/#{assets_dir}/"
          end
        else
          # Use AssetSync Gem to sync assets list to cloud
          # https://github.com/rumblelabs/asset_sync/blob/master/lib/tasks/asset_sync.rake#L5
          AssetSync.configure do |config|
            config.manifest_path = run_locally("ls #{assets_dir}/manifest*").strip!
            config.assets_prefix = 'assets'
            config.public_path = './public'

            cdn.each do |option, value|
              config.send("#{option}=", value)
            end

          end
          AssetSync.sync
        end
      end
    end
    before "deploy:assets:symlink", "deploy:assets:remove_manifest"
    after "deploy:assets:precompile", "deploy:assets:sync_manifest_to_app_servers",
      "deploy:assets:sync_assets_files", "deploy:assets:cleanup"
  end

  namespace :fast_assets do
    desc "check is local git commit same as the branch that deploying."
    task :valid do
      local_current_commit = `git rev-parse HEAD`.split(' ').strip.last[0..7]
      # if setup commit id on branch variable
      if local_current_commit.include?(branch.to_s)
        valid_pass "fast_assets need same commit id between local (#{local_current_commit}) and remote (#{branch})"
      else
        remote_branch_commit = `git ls-remote #{repository} #{branch}`.strip
        if remote_branch_commit.blank?
          valid_faild "Not found remote branch: #{branch}"
          exit
        elsif (deploying_commit = (remote_branch_commit.split(' ').first || '')[0..7]) == local_current_commit
          valid_pass "fast_assets need same commit id between local (#{local_current_commit}) and remote (#{deploying_commit})"
        else
          valid_faild "Local HEAD commit is (#{local_current_commit}), please checkout local branch to \"#{branch} (#{deploying_commit})\" same as you deployed."
          exit
        end
      end
    end
    before 'deploy:update', 'fast_assets:valid'
  end
end
