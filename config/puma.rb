# Change to match your CPU core count
workers 1

# Min and Max threads per worker
threads 1, 6

rails_env = ENV['RAILS_ENV'] || "production"

if rails_env == "production"
  shared_dir = "/home/ubuntu/apps/salsa/shared"
else
  shared_dir = "/home/apps/salsa"
end

# Default to production
environment rails_env


if rails_env != "development"
  # Set up socket location (if using a webserver such as nginx)
  bind "unix:///tmp/sockets/puma.sock"
# Logging
  stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true
else
  # Set up socket location (if using a webserver such as nginx)
  bind "unix://#{shared_dir}/tmp/sockets/puma.sock"

end

# Set master PID and state locations
pidfile "/tmp/pids/puma.pid"
state_path "/tmp/pids/puma.state"
activate_control_app

on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file(shared_dir+"/config/database.yml")[rails_env])
end
