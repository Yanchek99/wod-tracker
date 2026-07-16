class RenameWodImportsToWorkoutImports < ActiveRecord::Migration[8.1]
  def change
    rename_table :wod_imports, :workout_imports
    rename_column :workout_imports, :wod_date, :workout_date
  end
end
