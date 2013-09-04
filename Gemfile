source 'https://rubygems.org'
source 'https://8dezqz7z7HWea9vtaFwg:@gem.fury.io/me/' # thibaud@jilion.com account

ruby '2.0.0'

gem 'rails', '4.0.0'

gem 'sublime_video_layout', '~> 2.6' # hosted on gemfury
gem 'sublime_video_private_api', '~> 1.5' # hosted on gemfury

gem 'pg'
gem 'textacular'
gem 'sidekiq'
gem 'video_info'
gem 'addressable'
gem 'http_content_type'
gem 'fog'
gem 'oj'

gem 'honeybadger'
gem 'librato-rails'
gem 'librato-sidekiq'
gem 'rack-status'
gem 'has_scope'
gem 'newrelic_rpm'

group :staging, :production do
  gem 'unicorn'
  gem 'lograge'
  gem 'memcachier'
  gem 'dalli'
  gem 'rack-cache'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'rspec-rails'
end

group :development do
  gem 'annotate'

  # Guard
  gem 'ruby_gntp'
  gem 'guard-pow'
  gem 'guard-rspec'
end

group :test do
  gem 'rspec'
  gem 'shoulda-matchers'
  gem 'webmock', '>= 1.8.0', '< 1.10'
  gem 'vcr'
  gem 'factory_girl_rails'
end
