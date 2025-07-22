class CreateJoinTablePodcastsPublishers < ActiveRecord::Migration[8.0]
  def change
    create_join_table :podcasts, :publishers do |t|
      # t.index [:podcast_id, :publisher_id]
      # t.index [:publisher_id, :podcast_id]
    end
  end
end
