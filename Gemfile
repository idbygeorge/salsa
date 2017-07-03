source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.1.2'

group :development, :test do
  gem 'sqlite3'
  gem 'byebug'
  gem 'rspec-rails'
end

group :development do
  # Use Capistrano for deployment
  gem 'capistrano',         require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma',   require: false
  gem 'capistrano-rails-collection', require: false
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'listen'
end

#postgresql for db
gem 'pg'

group :production do
  gem 'rails_12factor'

  # Use puma as the app server
  gem 'puma'

  # newrelic for monitoring
  gem 'newrelic_rpm'
end

# preprocessors
gem 'sass-rails'
gem 'compass-rails'
gem 'coffee-rails'
gem 'uglifier'

# bootstrap
gem 'bootstrap-sass'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

#TODO: remove foundation
gem 'zurb-foundation'

# Add awesome nested set
gem 'awesome_nested_set'
# pagination
gem 'kaminari'
# active record version control
gem 'paper_trail'

# processing meta data for orgs and accounts
gem 'pivot_table'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

# for aws bucket usage
gem 'uber-s3'

# instructure canvas api
gem 'canvas-api'

gem 'nokogiri'

# background gem for long runnning tasks
gem 'que'

#gem for creating zip files
gem 'rubyzip'

# Use ActiveModel has_secure_password
gem 'bcrypt'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end
