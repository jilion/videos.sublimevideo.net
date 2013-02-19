source 'https://rubygems.org'
source 'https://8dezqz7z7HWea9vtaFwg@gem.fury.io/me/' # thibaud@jilion.com account

ruby '1.9.3'

gem 'rails',     github: 'rails/rails'
gem 'arel',      github: 'rails/arel'

gem 'sublime_video_private_api', '~> 1.0' # hosted on gemfury

gem 'pg'
gem 'sidekiq'
gem 'video_info'

gem 'airbrake'
gem 'librato-rails', github: 'librato/librato-rails', branch: 'feature/rack_first'

group :staging, :production do
  gem 'thin'
  gem 'lograge'
  gem 'dalli'
  gem 'rack-cache'
  gem 'newrelic_rpm'
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
