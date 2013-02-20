require 'sidekiq'

class VideoStatsMergerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'low'

  def perform(site_token, new_uid, old_uid)
    # method handled in mysv
  end
end
