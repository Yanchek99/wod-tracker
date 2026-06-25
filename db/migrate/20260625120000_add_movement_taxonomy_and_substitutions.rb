class AddMovementTaxonomyAndSubstitutions < ActiveRecord::Migration[8.1]
  def change
    add_column :movements, :family, :integer
    add_column :movements, :pattern, :integer
    add_column :movements, :equipment, :integer
    add_column :movements, :skill_level, :integer
    add_column :movements, :load_bearing, :boolean, null: false, default: false

    add_index :movements, :family
    add_index :movements, :pattern
    add_index :movements, :equipment
    add_index :movements, :skill_level

    create_table :movement_substitutions do |t|
      t.references :movement, null: false, foreign_key: true
      t.references :substitute_movement, null: false, foreign_key: { to_table: :movements }
      t.integer :direction, null: false

      t.timestamps
    end

    add_index :movement_substitutions,
              %i[movement_id substitute_movement_id],
              unique: true,
              name: 'idx_movement_substitutions_unique_pair'
  end
end
