class AddPlayerStageToVideoTags < ActiveRecord::Migration
  def change
    add_column :video_tags, :player_stage, :string, default: 'stable'
  end
end
