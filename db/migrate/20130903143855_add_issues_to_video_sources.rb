class AddIssuesToVideoSources < ActiveRecord::Migration
  def change
    add_column :video_sources, :issues, :string, array: true, default: []
  end
end
