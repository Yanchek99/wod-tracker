class CreateMetrics < ActiveRecord::Migration[5.2]
  def change
    create_table :metrics do |t|
      t.belongs_to :exercise
      t.belongs_to :measurement
      t.string :value

      t.timestamps
    end
  end
end
