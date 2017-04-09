# Change to match your CPU core count
workers 1

# Min and Max threads per worker
threads 1, 6

rails_env = ENV['RAILS_ENV'] || "development"

app_dir = File.expand_path("../..", __FILE__)

if rails_env == "production"
  shared_dir = "#{app_dir}/shared"
else
  shared_dir = app_dir
end

# Default to production
environment rails_env

# Set up socket location
bind "unix://#{shared_dir}/tmp/sockets/puma.sock"

# Logging
stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{shared_dir}/tmp/pids/puma.pid"
state_path "#{shared_dir}/tmp/pids/puma.state"
activate_control_app

on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
end
