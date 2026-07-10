class AddScraperUniquenessConstraints < ActiveRecord::Migration[8.1]
  def change
    add_index :programs, :name, unique: true
  end
end
