class UpdateVideoTagsIndexes < ActiveRecord::Migration
  def change
    add_index :video_tags, [:site_token, :uid], unique: true
    add_index :video_tags, [:site_token, :updated_at]
  end
end
