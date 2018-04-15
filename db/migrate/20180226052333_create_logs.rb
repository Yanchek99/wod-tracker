class CreateLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :logs do |t|
      t.belongs_to :user
      t.belongs_to :workout
      t.string :measurement_value

      t.timestamps
    end
  end
end
