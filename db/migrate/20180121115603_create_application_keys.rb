class CreateApplicationKeys < ActiveRecord::Migration[5.1]
  def change
    create_table :application_keys do |t|
      t.string :appName
      t.string :keyForUser
      t.string :keyForFilm
      t.string :keyForRating

      t.timestamps
    end
  end
end
