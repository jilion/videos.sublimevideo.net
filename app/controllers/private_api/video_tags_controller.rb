require 'has_scope'

class PrivateApi::VideoTagsController < SublimeVideoPrivateApiController
  has_scope :per, :search
  has_scope :last_30_days_active, :last_90_days_active, :last_365_days_active, type: :boolean
  has_scope :by_last_30_days_starts, :by_last_90_days_starts, :by_last_365_days_starts
  has_scope :by_date, :by_title
  has_scope :with_valid_uid, :with_invalid_uid, type: :boolean
  has_scope :select, :with_uids, type: :array

  # GET /private_api/sites/:site_token/video_tags
  def index
    @video_tags = VideoTag.where(site_token: params[:site_token]).by_title.page(params[:page])
    @video_tags = apply_scopes(@video_tags)

    expires_in 2.minutes, public: true
    respond_with(@video_tags)
  end

  # GET /private_api/sites/:site_token/video_tags/:id
  def show
    @video_tag = VideoTag.where(site_token: params[:site_token], uid: params[:id]).first!

    expires_in 2.minutes, public: true
    respond_with(@video_tag) if stale?(@video_tag, public: true)
  end

  # GET /private_api/sites/:site_token/video_tags/count
  def count
    @count = apply_scopes(VideoTag.where(site_token: params[:site_token])).count

    expires_in 2.minutes, public: true
    respond_with(count: @count)
  end
end
