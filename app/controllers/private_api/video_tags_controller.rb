class PrivateApi::VideoTagsController < SublimeVideoPrivateApiController

  def index
    @video_tags = VideoTag.page(params[:page])
    responds_with(@video_tags)
  end

end
