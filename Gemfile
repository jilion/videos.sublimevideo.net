source 'https://rubygems.org'
source 'https://8dezqz7z7HWea9vtaFwg@gem.fury.io/me/' # thibaud@jilion.com account

ruby '1.9.3'

gem 'rails', '4.0.0.beta1'

gem 'sublime_video_layout', '~> 2.6' # hosted on gemfury
gem 'coffee-rails', '4.0.0.beta1' # needed for sublime_video_layout

gem 'sublime_video_private_api', '~> 1.0' # hosted on gemfury
gem 'configurator', github: 'jilion/configurator'

gem 'pg'
gem 'sidekiq'
gem 'video_info'
gem 'fog'

gem 'airbrake'
gem 'librato-rails', github: 'librato/librato-rails', branch: 'feature/rack_first'

gem 'rack-status'
gem 'has_scope'
gem 'newrelic_rpm', '3.6.0.74.beta'

group :staging, :production do
  gem 'thin'
  gem 'lograge'
  gem 'dalli'
  gem 'rack-cache'
end

group :development, :test do
  gem 'rspec-rails'
end

group :development do
  gem 'annotate'

  # Guard
  gem 'ruby_gntp'
  gem 'rb-fsevent'

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
