class UpdateVideoTagsFields < ActiveRecord::Migration
  def change
    remove_index :video_tags, [:site_id, :uid]
    remove_index :video_tags, [:site_id, :updated_at]
    remove_column :video_tags, :site_id
    remove_column :video_tags, :current_sources
    change_column :video_tags, :uid_origin, :string, default: 'attribute'
    add_column :video_tags, :site_token, :string, null: false
  end
end
