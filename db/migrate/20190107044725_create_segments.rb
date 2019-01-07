class CreateSegments < ActiveRecord::Migration[5.2]
  def change
    create_table :segments do |t|
      t.belongs_to :workout, foreign_key: true
      t.integer :rounds
      t.integer :time
      t.integer :interval

      t.timestamps
    end

    add_reference :exercises, :segment, foreign_key: true
  end
end
