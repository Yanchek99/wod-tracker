class DropMetrics < ActiveRecord::Migration[8.1]
  # Score fields, exercise prescriptions, and movement-log performance have all been backfilled
  # onto their owning tables (see the add_*_fields migrations), so the polymorphic metrics table
  # is no longer read or written. The block lets the drop reverse cleanly back to the prior schema.
  def change
    drop_table :metrics do |t|
      t.datetime :created_at, precision: nil, null: false
      t.integer :female_value
      t.integer :male_value
      t.bigint :measurable_id
      t.string :measurable_type
      t.integer :measurement
      t.datetime :updated_at, precision: nil, null: false
      t.integer :value
      t.index %w[measurable_type measurable_id], name: 'index_metrics_on_measurable_type_and_measurable_id'
      t.index %w[measurement measurable_id measurable_type],
              name: 'index_metrics_on_measurement_and_measurable', unique: true
    end
  end
end
