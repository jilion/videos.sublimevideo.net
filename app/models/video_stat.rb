require 'sublime_video_private_api'

class VideoStat
  include SublimeVideoPrivateApi::Model
  uses_private_api :stats
  collection_path '/private_api/video_stats'

  def self.last_day_starts(video_uid, days)
    result = get_raw(:last_day_starts, id: video_uid, days: days)
    result[:parsed_data][:data][:starts]
  end
end
