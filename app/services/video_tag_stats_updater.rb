class VideoTagStatsUpdater
  attr_reader :video_tag

  def initialize(video_tag)
    @video_tag = video_tag
  end

  def update
    _update_video_tag_starts
    video_tag.starts_updated_at = Time.now
    video_tag.save
  end

  private

  def _update_video_tag_starts
    video_tag.starts += _new_starts
    video_tag.starts.shift(video_tag.starts.length - 365)
  end

  def _new_starts
    if _video_tag_without_activiy?
      _days_to_update.times.map { 0 }
    else
      VideoStat.last_day_starts(video_tag.uid, _days_to_update)
    end
  end

  def _days_to_update
    updated_at = video_tag.starts_updated_at || 366.days.ago
    ((updated_at - Time.now) / 1.day + 1).abs.round
  end

  def _video_tag_without_activiy?
    video_tag.updated_at == video_tag.starts_updated_at
  end
end
