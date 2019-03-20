class AddUnitToMetric < ActiveRecord::Migration[5.2]
  def change
    add_column :metrics, :unit, :string
  end
end
