class CreatePodcasts < ActiveRecord::Migration[8.0]
  def change
    create_table :podcasts do |t|
      t.string :title
      t.string :issn
      t.string :doi
      t.text :summary
      t.text :script
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :podcasts, :title, unique: true
    add_index :podcasts, :doi, unique: true
  end
end
