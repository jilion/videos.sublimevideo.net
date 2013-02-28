source 'https://rubygems.org'
source 'https://8dezqz7z7HWea9vtaFwg@gem.fury.io/me/' # thibaud@jilion.com account

ruby '2.0.0'

gem 'rails', '4.0.0.beta1'

gem 'sublime_video_private_api', '~> 1.0' # hosted on gemfury

gem 'pg'
gem 'sidekiq'
gem 'video_info'

gem 'airbrake'
gem 'librato-rails', github: 'librato/librato-rails', branch: 'feature/rack_first'

gem 'rack-status'
gem 'has_scope'
gem 'newrelic_rpm'

group :staging, :production do
  gem 'puma', '2.0.0.b6'
  gem 'lograge'
  gem 'dalli'
  gem 'rack-cache'
end

group :development, :test do
  gem 'rspec-rails'
end

group :test do
  gem 'shoulda-matchers'
  gem 'webmock'
  gem 'vcr'
  gem 'factory_girl_rails'
end

group :tools do
  gem 'annotate'

  # Guard
  gem 'ruby_gntp'
  gem 'rb-fsevent'

  gem 'guard-pow'
  gem 'guard-rspec'
end
