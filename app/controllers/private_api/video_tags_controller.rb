require 'has_scope'

class PrivateApi::VideoTagsController < SublimeVideoPrivateApiController
  has_scope :per
  has_scope :last_30_days_active, type: :boolean
  has_scope :select, :with_uids, type: :array

  def index
    @video_tags = VideoTag.where(site_token: params[:site_token]).page(params[:page])
    @video_tags = apply_scopes(@video_tags)

    respond_with(@video_tags)
  end

  def show
    @video_tag = VideoTag.where(site_token: params[:site_token], uid: params[:id]).first

    respond_with(@video_tag)
  end

  def count
    @count = apply_scopes(VideoTag.where(site_token: params[:site_token])).count

    respond_with(count: @count)
  end
end
