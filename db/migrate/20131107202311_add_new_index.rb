class AddNewIndex < ActiveRecord::Migration
  def change
    remove_index :video_tags, :starts_updated_at

    add_index :video_tags, [:site_token, :starts_updated_at, :started_at], order: { started_at: :desc }, name: 'index_update_starts'
  end
end
