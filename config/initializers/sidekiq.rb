require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = { size: 5 } # for web dyno
end
