require 'test_helper'

class MeasurableHelperMovementLogTest < ActionView::TestCase
  include MeasurableHelper
  include MetricsHelper

  test 'keeps movement log distances as additional metric text' do
    movement_log = logs(:matt_amrap).movement_logs.create!(movement: movements(:row),
                                                           distance: 300, distance_unit: :meter)

    assert_equal 'Row (300 meters)', measurable_message(movement_log)
  end

  test 'renders single-value target heights as ft after load' do
    wall_ball = Movement.create!(name: 'Wall-ball Shot')
    movement_log = logs(:matt_amrap).movement_logs.create!(movement: wall_ball,
                                                           reps: 30, load: 20, load_unit: :lb,
                                                           distance: 10, distance_unit: :foot)

    assert_equal '30 Wall-ball Shots (20 lbs / 10 ft)', measurable_message(movement_log)
  end

  test 'renders a movement log from its performance columns' do
    movement_log = logs(:matt_amrap).movement_logs.build(movement: movements(:row),
                                                         distance: 300, distance_unit: :meter)

    assert_equal 'Row (300 meters)', measurable_message(movement_log)
  end

  test 'renders additional distance before load for movement logs' do
    movement_log = logs(:matt_amrap).movement_logs.build(movement: movements(:row),
                                                         reps: 10, distance: 400,
                                                         distance_unit: :meter, load: 135,
                                                         load_unit: :lb)

    assert_equal '10 Rows (400 meters / 135 lbs)', measurable_message(movement_log)
  end

  test 'renders a movement log set breakdown in brackets after its reps, only when present' do
    movement_log = logs(:matt_amrap).movement_logs.build(movement: movements(:pullup), reps: 45, set_breakdown: [21, 15, 9])
    assert_equal '45 Pull Ups [21-15-9]', measurable_message(movement_log)

    movement_log.set_breakdown = []
    assert_equal '45 Pull Ups', measurable_message(movement_log)
  end

  test 'renders a movement log set breakdown grouped by round, dash-joined within a round' do
    log = logs(:brooke_fran)
    thruster_log = log.movement_logs.find { |ml| ml.movement == movements(:thruster) }
    thruster_log.reps = 45
    thruster_log.set_breakdown = [8, 7, 6, 8, 7, 9]

    assert_equal '45 Thrusters [8-7-6, 8-7, 9]', measurable_message(thruster_log)
  end
end
