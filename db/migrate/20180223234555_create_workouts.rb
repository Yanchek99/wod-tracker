class CreateWorkouts < ActiveRecord::Migration[5.2]
  def change
    create_table :workouts do |t|
      t.string :name
      t.integer :rounds
      t.integer :time
      t.string :interval
      t.integer :measurement

      t.timestamps
    end
  end
end
