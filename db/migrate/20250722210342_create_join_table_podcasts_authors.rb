class CreateJoinTablePodcastsAuthors < ActiveRecord::Migration[8.0]
  def change
    create_join_table :podcasts, :authors do |t|
      # t.index [:podcast_id, :author_id]
      # t.index [:author_id, :podcast_id]
    end
  end
end
