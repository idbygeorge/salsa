source 'https://rubygems.org'

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem 'rails', '5.2.2'

gem 'bootsnap'
group :development, :test do
  gem 'byebug'
  gem 'factory_bot'
  gem 'factory_bot_rails', '~> 4.0'
  gem 'faker', git: 'https://github.com/stympy/faker.git', branch: 'master'
  gem 'rspec-rails'
  gem 'simplecov', require: false
  gem 'sqlite3'
end

group :development do
  gem 'scout_apm'
  # Use Capistrano for deployment
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano',         require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-figaro-yml', '~> 1.0.2', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rails-collection', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano3-puma', require: false
  gem 'listen'
  gem 'meta_request'
end
group :test do
  gem 'capybara-mechanize'
  gem 'capybara-webkit'
  gem 'cucumber-rails', require: false
  gem 'fakeweb', git: 'https://github.com/chrisk/fakeweb.git', branch: 'master'
  gem 'launchy'
  # database_cleaner is not required, but highly recommended
  gem 'database_cleaner'
end

gem 'seed_dump'

# postgresql for db
gem 'pg', '0.20'

gem 'devise_saml_authenticatable'

group :production do
  gem 'rails_12factor'

  # Use puma as the app server
  gem 'puma'

  # newrelic for monitoring
  gem 'newrelic_rpm'
end

# preprocessors
gem 'coffee-rails'
gem 'compass-rails'
gem 'haml-rails', '~> 1.0'
gem 'sass-rails'
gem 'uglifier'

# twitter bootstrap
gem 'twitter-bootstrap-rails'

# bootstrap
gem 'bootstrap-sass'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# TODO: remove foundation
gem 'zurb-foundation'
# for mailer templates
gem 'liquid'
# Add awesome nested set
gem 'awesome_nested_set'
# pagination
gem 'kaminari'
# active record version control
gem 'paper_trail'

# for env variables
gem 'figaro'

# processing meta data for orgs and accounts
gem 'pivot_table'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

# for aws bucket usage
gem 'aws-sdk-s3', '~> 1'
gem 'uber-s3'

# instructure canvas api
gem 'canvas-api', '0.7'

gem 'nokogiri'

# background gem for long runnning tasks
gem 'que'

# gem for creating zip files
gem 'rubyzip'

# Use ActiveModel has_secure_password
gem 'bcrypt'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end
