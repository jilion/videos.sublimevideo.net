class UpdateVideoTagsFields < ActiveRecord::Migration
  def change
    remove_index :video_tags, [:site_id, :uid]
    remove_index :video_tags, [:site_id, :updated_at]
    remove_column :video_tags, :site_id
    change_column :video_tags, :uid_origin, :string, default: 'attribute'
    add_column :video_tags, :options, :hstore
    add_index :video_tags, [:site_token, :uid], unique: true
    add_index :video_tags, [:site_token, :updated_at]
    rename_column :video_tags, :name, :title
    rename_column :video_tags, :name_origin, :title_origin
  end
end