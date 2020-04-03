class AddMissingUniqueConstraints < ActiveRecord::Migration[6.0]
  def change
    add_index :exercises, [:position, :workout_id], unique: true
    add_index :movements, :name, unique: true
  end
end
