class RenameBikeMovementToAirBike < ActiveRecord::Migration[8.1]
  def up
    movement = Movement.find_by(name: 'Bike')
    return unless movement

    movement.update!(name: 'Air Bike')
  end

  def down
    movement = Movement.find_by(name: 'Air Bike')
    return unless movement

    movement.update!(name: 'Bike')
  end
end
