class AddSourceToWorkouts < ActiveRecord::Migration[8.1]
  def change
    add_column :workouts, :source, :string
    add_column :workouts, :source_ref, :string
    add_index :workouts, %i[source source_ref], unique: true
  end
end
