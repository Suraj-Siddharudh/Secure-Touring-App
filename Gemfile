source 'https://rubygems.org'

ruby file: '.ruby-version'

gem 'rails', '~> 8.1'
gem 'sprockets-rails'
gem 'puma', '>= 6.4'

# Assets
gem 'dartsass-sprockets'
gem 'terser'
gem 'turbolinks', '~> 5'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.13'

# Auth
gem 'devise'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'

# Uploads
gem 'carrierwave', '~> 3.0'
gem 'mini_magick'

gem 'city-state'
gem 'faker'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

group :development, :test do
  # SQLite for local development and tests
  gem 'sqlite3', '>= 2.1'
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
end

group :development do
  gem 'web-console'
end

group :production do
  # PostgreSQL in production (configured through DATABASE_URL)
  gem 'pg'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]
