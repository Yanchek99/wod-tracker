class AddSexSpecificValuesToMetrics < ActiveRecord::Migration[8.1]
  def change
    add_column :metrics, :female_value, :integer
    add_column :metrics, :male_value, :integer
  end
end
