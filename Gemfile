source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

group :development, :test do
  gem 'sqlite3'
  gem 'debugger'
end

group :development do
  # Use Capistrano for deployment
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
end

group :production do
  #postgresql for production db
  gem 'pg'
  
  gem 'rails_12factor'
  
  # Use unicorn as the app server
  gem 'unicorn'

  # newrelic for monitoring
  gem 'newrelic_rpm'
end

# preprocessors
gem 'sass-rails', '~> 4.0.0'
gem 'compass-rails'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'

# bootstrap
gem 'bootstrap-sass'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

#TODO: remove foundation
gem 'zurb-foundation'

# Add awesome nested set
gem 'awesome_nested_set', '~> 3.0.0.rc.3'
# pagination
gem 'kaminari'
# active record version control
gem 'vestal_versions', :git => 'git://github.com/laserlemon/vestal_versions'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# for aws bucket usage
gem 'uber-s3'

# instructure canvas api
gem 'canvas-api'


# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end