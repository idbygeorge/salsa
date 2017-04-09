set :repo_url,        'https://github.com/idbygeorge/salsa.git'
set :branch, ENV.fetch("CAPISTRANO_BRANCH", "master")
set :application,     'salsa'
set :user,            'ubuntu'
set :puma_threads,    [4, 16]
set :puma_workers,    0

# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

set :puma_bind,       "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, false  # Change to true if using ActiveRecord

set :ssh_options,     { forward_agent: true }

set :linked_files, %w{config/database.yml config/config.yml public/500.html public/422.html public/404.html}

# instances/custom view folder is not part of the public repository
# any customization instance views will need to be added to the server another way
set :linked_dirs, %w{app/views/instances/custom public/assets/scripts}

## Defaults:
# set :scm,           :git
# set :branch,        :master
# set :format,        :pretty
# set :log_level,     :debug
# set :keep_releases, 5

## Linked Files & Directories (Default None):
# set :linked_files, %w{config/database.yml}
# set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      before 'deploy', 'setup'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  desc 'Copy config files to server'
  task :copy_config do
    on release_roles :app do |role|
      if File.exists?('config/newrelic-#{rails_env}.yml')
        linked_files.push('config/newrelic-#{rails_env}.yml')
      end

      if File.exists?('config/puma-#{rails_env}.rb')
        linked_files.push('config/puma-#{rails_env}.rb')
      end

      remote_files = linked_files(shared_path)

      fetch(:linked_files).each do |linked_file|
        run_locally do
          if File.exist?(linked_file)
              remote_file = linked_file.sub! '-', '_' || linked_file
              puts "#{linked_file} #{role}:#{shared_path}/#{remote_file}"
            # execute :rsync, linked_file, "#{role}:#{shared_path}/#{linked_file.sub! "-#{role}", ''}"
          end
        end
      end
    end
  end

  before "check:linked_files", :copy_config
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma
