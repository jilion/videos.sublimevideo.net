source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails',     github: 'rails/rails'
gem 'arel',      github: 'rails/arel'

gem 'pg'

group :staging, :production do
  gem 'thin'
  gem 'dalli'
  gem 'rack-cache'
  gem 'newrelic_rpm'
end
