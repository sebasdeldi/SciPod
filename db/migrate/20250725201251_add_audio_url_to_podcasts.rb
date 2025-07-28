class AddAudioUrlToPodcasts < ActiveRecord::Migration[8.0]
  def change
    add_column :podcasts, :audio_url, :string
  end
end
