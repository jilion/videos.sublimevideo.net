class AddVideoTagStartedAt < ActiveRecord::Migration
  def change
    remove_index :video_tags, [:site_token, :loaded_at]
    remove_index :video_tags, :loaded_at

    rename_column :video_tags, :loaded_at, :started_at

    add_index :video_tags, [:site_token, :started_at]
    add_index :video_tags, :started_at
    add_index :video_tags, [:site_token, :created_at]
    add_index :video_tags, [:site_token, :title]
  end
end
