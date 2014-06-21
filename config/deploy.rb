# TODO: this file shouldn't be tracked... each instance may be different

# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'salsa'
set :repo_url, 'https://github.com/idbygeorge/salsa.git'

# Default branch is :master
set :branch, 'master' # proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/u/apps/salsa'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/config.yml config/newrelic.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# instances/custom view folder is not part of the public repository
# any customization instance views will need to be added to the server another way
set :linked_dirs, %w{app/views/instances/custom public/assets/ckeditor}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "kill -s USR2 `cat /tmp/unicorn.salsa.pid`"
    end
  end

  after :publishing, :restart

end
