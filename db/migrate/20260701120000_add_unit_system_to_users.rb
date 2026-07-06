class AddUnitSystemToUsers < ActiveRecord::Migration[8.1]
  def change
    # Display preference only: loads are stored canonically in pounds, and this chooses whether an
    # athlete sees pounds (imperial) or kilograms (metric). Defaults to imperial, matching the
    # existing lb-only display.
    add_column :users, :unit_system, :integer, default: 0, null: false
  end
end
