require 'sidekiq'

Sidekiq.configure_server do |config|
  if database_url = ENV['DATABASE_URL']
    ENV['DATABASE_URL'] = "#{database_url}?pool=30"
    ActiveRecord::Base.establish_connection
  end
end

Sidekiq.configure_client do |config|
  config.redis = { size: 2 } # for web dyno
end
