require 'sidekiq'
require 'librato-sidekiq'

Librato::Sidekiq::Middleware.configure do |c|
  c.enabled = Rails.env.production?
end
