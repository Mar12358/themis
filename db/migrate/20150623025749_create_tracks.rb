class CreateTracks < ActiveRecord::Migration[7.0]
  def change
    create_table :tracks do |t|
      t.string :code

      t.timestamps null: false
    end
  end
end
