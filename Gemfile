source 'https://rubygems.org'
source 'https://8dezqz7z7HWea9vtaFwg@gem.fury.io/me/' # thibaud@jilion.com account

ruby '2.0.0'

# gem 'rails', '4.0.0.beta1' # for migration, https://github.com/rails/rails/pull/10482
gem 'rails', github: 'rails/rails', branch: '4-0-stable'
# gem 'rails', '4.0.0-rc1'

gem 'sublime_video_layout', '~> 2.6' # hosted on gemfury
gem 'coffee-rails', '4.0.0.beta1' # needed for sublime_video_layout

gem 'sublime_video_private_api', '~> 1.0' # hosted on gemfury

gem 'pg'
gem 'sidekiq'
gem 'video_info'
gem 'fog'
gem 'oj'

gem 'honeybadger'
gem 'librato-rails', github: 'librato/librato-rails', branch: 'feature/rack_first'
gem 'librato-sidekiq'
gem 'rack-status'
gem 'has_scope'
gem 'newrelic_rpm'

group :staging, :production do
  gem 'unicorn'
  gem 'lograge'
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
