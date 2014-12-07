# source 'http://ruby.taobao.org/'
source 'https://rubygems.org'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.3'
gem 'sinatra', '>= 1.3.0', :require => nil
# Use sqlite3 as the database for Active Record
gem 'pg'

gem 'redis'
gem 'i18n-js'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'
gem 'simple_form'
gem 'angular-rails-templates'

gem 'opbeat'

group :development, :test do
  gem 'rspec-rails'
  gem "factory_girl_rails"
  gem 'database_cleaner'
  gem 'coffee-rails-source-maps'
  gem 'better_errors'
  gem "jasminerice", :git => 'https://github.com/bradphelan/jasminerice.git'
  gem 'pry-rails'
end

group :production do
  gem 'rails_log_stdout', github: 'heroku/rails_log_stdout'
  gem 'rails3_serve_static_assets', github: 'heroku/rails3_serve_static_assets'
end

gem 'bootstrap-sass', '~> 3.3.0'
gem 'sass-rails', '>= 3.2' # sass-rails needs to be higher than 3.2
gem 'autoprefixer-rails'

gem "sorcery"

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'gon'

gem 'sidekiq'
gem 'sidetiq'
gem 'zeus'
# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

gem 'simplecov', :require => false, :group => :test

# Use Capistrano for deployment
gem 'rvm-capistrano', group: :development

gem 'capybara', group: :test
gem 'selenium-webdriver', group: :test
# Use debugger
# gem 'debugger', group: [:development, :test]

