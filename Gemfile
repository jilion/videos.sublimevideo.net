source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails',     github: 'rails/rails'
gem 'arel',      github: 'rails/arel'

gem 'pg'

gem 'sidekiq'

gem 'video_info'

gem 'airbrake'
gem 'librato-rails', github: 'librato/librato-rails', branch: 'feature/rack_first'
gem 'lograge'

group :staging, :production do
  gem 'thin'
  gem 'dalli'
  gem 'rack-cache'
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'rspec-rails'
end

group :test do
  gem 'shoulda-matchers'
  gem 'turn', require: false
  gem 'faraday'
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
