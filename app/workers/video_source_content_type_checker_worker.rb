require 'sidekiq'
require 'http_content_type'

class VideoSourceContentTypeCheckerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'videos_low'

  def perform(video_source_id)
    return unless video_source = VideoSource.where(id: video_source_id).first

    video_source.issues = _video_source_issues(video_source.url)

    Librato.increment 'video_source.content_type_check'
    video_source.save
  end

  private

  def _video_source_issues(url)
    checker = HttpContentType::Checker.new(url)

    return ['not-found'] unless checker.found?
    return ['content-type-error'] unless checker.valid_content_type?

    []
  end

end
