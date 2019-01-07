class RemoveRxFromExercises < ActiveRecord::Migration[5.2]
  def change
    remove_column :exercises, :male_rx, :integer
    remove_column :exercises, :female_rx, :integer
  end
end
