class AddMovementTaxonomyAndSubstitutions < ActiveRecord::Migration[8.1]
  def change
    add_column :movements, :family, :integer
    add_column :movements, :equipment, :integer
    add_column :movements, :skill_level, :integer

    add_index :movements, :family
    add_index :movements, :equipment
    add_index :movements, :skill_level

    create_table :movement_function_roles do |t|
      t.references :movement, null: false, foreign_key: true
      t.integer :movement_function, null: false
      t.integer :role, null: false

      t.timestamps
    end

    add_index :movement_function_roles, :movement_function
    add_index :movement_function_roles, :role
    add_index :movement_function_roles,
              %i[movement_id movement_function],
              unique: true,
              name: 'idx_movement_function_roles_unique'

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
