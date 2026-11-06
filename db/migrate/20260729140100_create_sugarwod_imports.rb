class CreateSugarwodImports < ActiveRecord::Migration[8.1]
  def change
    create_table :sugarwod_imports do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: 'pending'
      t.integer :imported_count, null: false, default: 0
      t.integer :already_imported_count, null: false, default: 0
      t.integer :skipped_count, null: false, default: 0
      t.jsonb :skipped_rows, null: false, default: []
      t.timestamps
    end
  end
end
