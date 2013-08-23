# config/unicorn.rb
if ENV["RAILS_ENV"] == "development"
  worker_processes 10
else
  worker_processes 10
end

timeout 30