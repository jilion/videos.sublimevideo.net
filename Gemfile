source 'https://rubygems.org'
source 'https://8dezqz7z7HWea9vtaFwg:@gem.fury.io/me/' # thibaud@jilion.com account

ruby '2.1.2'

gem 'rails', '4.0.5'

gem 'sublime_video_layout', '~> 2.6' # hosted on gemfury
gem 'sublime_video_private_api', '~> 1.5' # hosted on gemfury

gem 'pg'
gem 'textacular'
gem 'sidekiq'
gem 'video_info'
gem 'addressable'
gem 'http_content_type'
gem 'fog'
gem 'unf'
gem 'oj'
gem 'faraday', '~> 0.8.9'

gem 'honeybadger'
gem 'librato-rails'
gem 'librato-sidekiq'
gem 'rack-status'
gem 'has_scope'
gem 'newrelic_rpm'

group :staging, :production do
  gem 'unicorn'
  gem 'lograge'
  gem 'dalli'
  gem 'memcachier'
  gem 'rack-cache'
  gem 'rails_12factor'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'rspec-rails'
end

group :development do
  gem 'annotate', require: false

  # Guard
  gem 'ruby_gntp', require: false
  gem 'guard-pow', require: false
  gem 'guard-rspec', require: false
end

group :test do
  gem 'rspec'
  gem 'shoulda-matchers'
  gem 'webmock'
  gem 'vcr'
  gem 'factory_girl_rails'
end
