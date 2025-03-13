class ChangeMeasurementToEnumInMetric < ActiveRecord::Migration[8.0]
  def up
    # Step 1: Add a temporary integer column
    add_column :metrics, :measurement_int, :integer

    # Step 2: Map existing string values to integers
    measurement_mapping = {
      'calorie' => 0, 'rep' => 1, 'round' => 2, 'seconds' => 3,
      'inch' => 4, 'foot' => 5, 'meter' => 6,
      'lb' => 7, 'kg' => 8,
      'time' => 9, 'weight' => 10, 'height' => 11, 'distance' => 12
    }

    Metric.reset_column_information
    Metric.find_each do |metric|
      if measurement_mapping.key?(metric.measurement)
        metric.update_columns(measurement_int: measurement_mapping[metric.measurement])
      end
    end

    # Step 3: Remove old string column and rename new column
    remove_column :metrics, :measurement
    rename_column :metrics, :measurement_int, :measurement
  end

  def down
    # Rollback: Convert integer back to string
    add_column :metrics, :measurement_str, :string

    measurement_mapping = {
      0 => 'calorie', 1 => 'rep', 2 => 'round', 3 => 'seconds',
      4 => 'inch', 5 => 'foot', 6 => 'meter',
      7 => 'lb', 8 => 'kg',
      9 => 'time', 10 => 'weight', 11 => 'height', 12 => 'distance'
    }

    Metric.reset_column_information
    Metric.find_each do |metric|
      if measurement_mapping.key?(metric.measurement)
        metric.update_columns(measurement_str: measurement_mapping[metric.measurement])
      end
    end

    remove_column :metrics, :measurement
    rename_column :metrics, :measurement_str, :measurement
  end
end
