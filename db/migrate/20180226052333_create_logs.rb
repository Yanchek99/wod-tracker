class CreateLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :logs do |t|
      t.references :workout
      t.string :measurement_value
      t.integer :measurement

      t.timestamps
    end
  end
end
