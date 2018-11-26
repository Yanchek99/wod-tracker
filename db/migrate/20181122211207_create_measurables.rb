class CreateMeasurables < ActiveRecord::Migration[5.2]
  def change
    create_table :measurables do |t|
      t.string :type
      t.references :movement, foreign_key: true
      t.references :assignable, polymorphic: true, index: true
      t.integer :reps
      t.integer :weight
      t.integer :seconds
      t.integer :height
      t.integer :distance
      t.integer :calories

      t.timestamps
    end


    drop_table :exercises
    drop_table :movement_logs
  end
end
