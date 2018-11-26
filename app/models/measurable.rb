class Measurable < ApplicationRecord
  belongs_to :movement
  belongs_to :assignable, polymorphic: true

  def copyable_attributes
    { movement: movement,
      reps: reps,
      seconds: seconds,
      calories: calories,
      weight: weight,
      height: height,
      distance: distance }
  end
end
