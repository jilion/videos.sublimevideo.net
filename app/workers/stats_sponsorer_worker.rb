require 'sidekiq'

class StatsSponsorerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'my-low'

  SPONSORED_DOMAINS = %w[dmcloud.net dailymotion.com]

  def self.perform_async_if_needed(video_tag)
    if video_tag.sources.map(&:url).any? { |url| url =~ %r{#{SPONSORED_DOMAINS.join('|')}} }
      perform_async(video_tag.site_token)
    end
  end

  def perform(site_token)
    # method handled in mysv
  end
end
