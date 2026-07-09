class CreateWodImports < ActiveRecord::Migration[8.1]
  def change
    create_table :wod_imports do |t|
      t.date :wod_date, null: false
      t.string :status, null: false
      t.text :raw_text
      t.text :error_message

      t.timestamps
    end

    add_index :wod_imports, :wod_date, unique: true
  end
end
