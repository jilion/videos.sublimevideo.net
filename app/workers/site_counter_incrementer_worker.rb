require 'sidekiq'

class SiteCounterIncrementerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform(site_token, counter_name)
    # method handled in mysv
  end
end
