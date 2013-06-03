require 'sublime_video_private_api'

class VideoStat
  include SublimeVideoPrivateApi::Model
  uses_private_api :stats
  collection_path '/private_api/sites/:site_token/video_stats'

  def self.last_day_starts(video_tag, days)
    result = get_raw(:last_day_starts, id: video_tag.uid, _site_token: video_tag.site_token, days: days)
    result[:parsed_data][:data][:starts]
  end
end
