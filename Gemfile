source 'http://rubygems.org'

gem 'rails', '~> 4.1.8'

gem 'spree_core', :github => 'spree/spree', :branch => '2-4-stable'
gem 'spree_api'

#spree_auth_devise requires this gems :/
gem 'sass-rails'
gem 'coffee-rails', '~> 4.0.0'
gem 'spree_auth_devise', :git => 'https://github.com/spree/spree_auth_devise.git', :branch => '2-4-stable'
gem 'mercadopago-sdk'

group :test do
  gem 'webmock'
  gem 'capybara'
  gem 'rspec-rails', '~> 2.14'
end

group :development, :test do
  gem 'zeus', require: false
  gem 'sqlite3'
  gem 'ffaker'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'therubyracer'
end

group :development do
  gem 'annotate', '>=2.6.0'
end

gemspec
