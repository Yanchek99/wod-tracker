class AddMovementTaxonomyAndSubstitutions < ActiveRecord::Migration[8.1]
  CLEAN_SQUAT_NAME = 'Clean Squat'.freeze
  SQUAT_CLEAN_NAME = 'Squat Clean'.freeze

  def up
    add_movement_taxonomy_columns
    create_movement_function_roles
    create_movement_substitutions
    reconcile_movement_name(from: CLEAN_SQUAT_NAME, to: SQUAT_CLEAN_NAME)
  end

  def down
    drop_movement_substitutions
    drop_movement_function_roles
    reconcile_movement_name(from: SQUAT_CLEAN_NAME, to: CLEAN_SQUAT_NAME)
    remove_movement_taxonomy_columns
  end

  private

  def add_movement_taxonomy_columns
    change_table :movements, bulk: true do |t|
      t.integer :family
      t.integer :equipment
      t.integer :skill_level
      t.index :family
      t.index :equipment
      t.index :skill_level
    end
  end

  def remove_movement_taxonomy_columns
    change_table :movements, bulk: true do |t|
      t.remove_index column: :skill_level
      t.remove_index column: :equipment
      t.remove_index column: :family
      t.remove :skill_level
      t.remove :equipment
      t.remove :family
    end
  end

  def create_movement_function_roles
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
  end

  def drop_movement_function_roles
    remove_index :movement_function_roles, name: 'idx_movement_function_roles_unique'
    remove_index :movement_function_roles, :role
    remove_index :movement_function_roles, :movement_function
    drop_table :movement_function_roles
  end

  def create_movement_substitutions
    create_table :movement_substitutions do |t|
      t.references :movement, null: false, foreign_key: true
      t.references :substitute_movement, null: false, foreign_key: { to_table: :movements }
      t.integer :direction, null: false

      t.timestamps
    end

    add_index :movement_substitutions,
              'LEAST(movement_id, substitute_movement_id), GREATEST(movement_id, substitute_movement_id)',
              unique: true,
              name: 'idx_movement_substitutions_unique_unordered_pair'
  end

  def drop_movement_substitutions
    remove_index :movement_substitutions, name: 'idx_movement_substitutions_unique_unordered_pair'
    drop_table :movement_substitutions
  end

  def reconcile_movement_name(from:, to:)
    from_id = movement_id_for(from)
    return if from_id.blank?

    to_id = movement_id_for(to)
    if to_id.present?
      reassign_movement_references(from_id:, to_id:)
      delete_movement(from_id)
    else
      rename_movement(from:, to:)
    end
  end

  def movement_id_for(name)
    select_value("SELECT id FROM movements WHERE lower(name) = lower(#{quote(name)}) LIMIT 1")
  end

  def reassign_movement_references(from_id:, to_id:)
    execute "UPDATE exercises SET movement_id = #{quote(to_id)} WHERE movement_id = #{quote(from_id)}"
    execute "UPDATE movement_logs SET movement_id = #{quote(to_id)} WHERE movement_id = #{quote(from_id)}"
  end

  def delete_movement(movement_id)
    execute "DELETE FROM movements WHERE id = #{quote(movement_id)}"
  end

  def rename_movement(from:, to:)
    execute "UPDATE movements SET name = #{quote(to)} WHERE lower(name) = lower(#{quote(from)})"
  end
end
