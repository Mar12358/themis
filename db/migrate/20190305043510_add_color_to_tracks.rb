class AddColorToTracks < ActiveRecord::Migration[7.0]
  def change
    add_column :tracks, :color, :string
  end
end
