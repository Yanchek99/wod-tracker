class AddUniqueIndexToMetrics < ActiveRecord::Migration[8.0]
  def change
    add_index :metrics, [:measurement, :measurable_id, :measurable_type], unique: true, name: "index_metrics_on_measurement_and_measurable"
  end
end
