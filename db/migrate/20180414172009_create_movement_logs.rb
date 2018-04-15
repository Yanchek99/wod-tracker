class CreateMovementLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :movement_logs do |t|
      t.belongs_to :log, foreign_key: true
      t.belongs_to :movement, foreign_key: true
      t.string :measurement_value

      t.timestamps
    end
  end
end
