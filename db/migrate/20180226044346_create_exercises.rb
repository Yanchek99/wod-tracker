class CreateExercises < ActiveRecord::Migration[5.2]
  def change
    create_table :exercises do |t|
      t.references :workout, foreign_key: true
      t.references :movement, foreign_key: true
      t.integer :reps
      # t.string :measurement
      t.string :measurement_value
      t.integer :male_rx
      t.integer :female_rx

      t.timestamps
    end
  end
end
