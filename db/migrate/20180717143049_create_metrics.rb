class CreateMetrics < ActiveRecord::Migration[5.2]
  def change
    create_table :metrics do |t|
      t.references :measurable, polymorphic: true, index: true
      t.string :measurement
      t.integer :value

      t.timestamps
    end
  end
end
