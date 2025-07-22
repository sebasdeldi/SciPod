class CreateFavorites < ActiveRecord::Migration[8.0]
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :podcast, null: false, foreign_key: true

      t.timestamps
    end

    # Ensure a user can only favorite a podcast once
    add_index :favorites, [:user_id, :podcast_id], unique: true
  end
end
