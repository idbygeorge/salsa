# Change to match your CPU core count
workers 1

# Min and Max threads per worker
threads 1, 6

rails_env = ENV['RAILS_ENV'] || "production"

if rails_env == "production"
  shared_dir = "/home/ubuntu/apps/salsa/shared"
else
  shared_dir = "/tmp"
end

# Default to production
environment rails_env

# Set up socket location (if using a webserver such as nginx)
bind "unix:///tmp/sockets/puma.sock"

# Logging
# stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "/tmp/pids/puma.pid"
state_path "/tmp/pids/puma.state"
activate_control_app

on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file("/home/ubuntu/apps/salsa/shared/config/database.yml")[rails_env])
end
