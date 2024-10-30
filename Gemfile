# frozen_string_literal: true

source 'https://rubygems.org'
ruby '>= 3.1.2' # must be Ruby >= 2.1 for letsencrypt dependency https://github.com/unixcharles/acme-client

gem 'rails', '~> 6.1.7.9'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg', '1.2.3'

# Gems used only for assets and not required
# in production environments by default.
gem 'coffee-rails', '5.0.0'
gem 'sass', '3.7.4'
gem 'sass-rails', '6.0.0'

gem 'activeadmin', '~> 3.2.0'
gem 'aws-sdk', '~> 3' # for backend upload
gem 'aws-sdk-s3', require: false
gem 'bootsnap', require: false
gem 'cancancan', '3.1.0'
gem 'carrierwave', '~> 2.2.6'
gem 'devise', '4.7.3'
gem 'exception_notification', '4.4.3'
gem 'factory_bot_rails', '6.1.0'
gem 'fog'
gem 'jquery-rails', '~> 4.4'
gem 'jquery-ui-rails', '~> 7.0.0', git: 'https://github.com/jquery-ui-rails/jquery-ui-rails'
gem 'letsencrypt_plugin', '0.0.12'
gem 'newrelic_rpm', '6.13.1'
gem 'paper_trail', '~> 13.0.0'
gem 'prawn', git: 'https://github.com/prawnpdf/prawn', ref: '3658d5125c3b20eb11484c3b039ca6b89dc7d1b7'
gem 'prawn-table', '0.2.1'
gem 's3_direct_upload' # for frontend upload
gem 'slim-rails', '3.2.0'
gem 'test-unit', '3.3.6' # fix can not enter rails console
gem 'tinymce-rails', '5.5.1'
gem 'uglifier', '4.2.0'
gem 'wicked_pdf', '~> 2.1.0'
gem 'wkhtmltopdf-binary', '~> 0.12.6.4'
gem 'wkhtmltopdf-heroku', '2.12.6.1.pre.jammy'

group :test, :development do
  gem 'brakeman', '~> 5.2.0', require: false
  gem 'byebug', '11.1.3'
  gem 'dotenv-rails', '2.7.6'
  gem 'letter_opener', '1.7.0'
  gem 'listen', '~> 3.7.0'
  gem 'pry', '0.13.1'
end

group :test do
  gem 'capybara', '3.33.0'
  gem 'database_cleaner', '1.8.5'
  gem 'rspec-rails', '~> 6.0.0'
  gem 'selenium-webdriver', '3.142.7'
  gem 'shoulda-matchers', '~> 5.0.0'
  gem 'sqlite3', '1.4.2'
  gem 'webrat', '0.7.3'
end

group :production do
  gem 'unicorn', '5.7.0'
  gem 'unicorn-worker-killer', '0.4.4'
end

gem 'hiredis', '~> 0.6'
gem 'redis', '~> 5.0.6'
gem 'sidekiq', '~> 7.1.0'
gem 'sidekiq-failures'
gem 'sidekiq-unique-jobs'

gem 'combine_pdf', '~> 1.0'

gem 'net-imap', require: false
gem 'net-pop', require: false
gem 'net-smtp', require: false
gem 'psych', '< 4' # required to specify psych version in rails 6 to avoid unknown alias issue
gem 'recaptcha', '~> 5.12'
gem 'sentry-rails'
gem 'sentry-ruby'

gem 'annotate'

gem 'rubocop', '~> 1.56'
gem 'rubocop-capybara', require: false
gem 'rubocop-performance', require: false
gem 'rubocop-rails', require: false
gem 'rubocop-rspec', require: false

gem 'bundler-audit', '~> 0.9.1'
