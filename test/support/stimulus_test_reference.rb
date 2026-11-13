# A small, fixed reference table for calculator tests, so the drafted production table
# (config/stimulus_reference.yml) can change without breaking exact-number tests.
module StimulusTestReference
  CONSTANTS = {
    'transition_seconds' => 10, 'slow_factor' => 2, 'heavy_boundary' => 0.85, 'female_reference_factor' => 0.7,
    'chunk_reps' => { 'light' => 15, 'moderate' => 7, 'heavy' => 2 },
    'effort_seconds' => { 'sprint' => 60, 'hard' => 180, 'threshold' => 600 },
    'heavy_rest_seconds' => [180, 300], 'heavy_working_percent_low' => 80
  }.freeze

  private

  def test_reference
    StimulusReference.new(
      'constants' => CONSTANTS,
      'lift_classes' => { 'olympic' => { 'light_below' => 0.45 }, 'barbell' => { 'light_below' => 0.50 } },
      'movements' => {
        'Thruster' => loaded(205, 'barbell', 2.0, 2.5, 4.0),
        'Deadlift' => loaded(425, 'barbell', 1.5, 2.0, 5.0),
        'Back Squat' => loaded(345, 'barbell', 2.0, 3.0, 6.0),
        'Clean and Jerk' => loaded(255, 'olympic', 4.0, 6.0, 12.0),
        'Pull Up' => { 'paces' => { 'rep' => 1.5 }, 'source' => 'test' },
        'Handstand Push-up' => { 'paces' => { 'rep' => 3.0 }, 'source' => 'test' },
        'Run' => { 'paces' => { 'meter' => 0.25 }, 'source' => 'test' }
      }
    )
  end

  def loaded(reference_load, lift_class, light, moderate, heavy)
    { 'paces' => { 'rep' => { 'light' => light, 'moderate' => moderate, 'heavy' => heavy } },
      'reference_load' => reference_load, 'lift_class' => lift_class, 'source' => 'test' }
  end

  # A persisted workout with one segment. movements: exercise attribute hashes.
  def build_workout(name, movements:, score_type: :time, **segment)
    workout = Workout.create!(name:, score_type:)
    seg = workout.segments.create!(position: 1, **segment)
    movements.each.with_index(1) { |attrs, position| seg.exercises.create!(position:, **attrs) }
    workout.reload
  end

  def fran
    build_workout('Fran Calc', interval_scheme: '21-15-9',
                               movements: [{ movement: movements(:thruster), reps: 1, male_load: 95, female_load: 65,
                                             load_unit: :lb },
                                           { movement: movements(:pullup), reps: 1 }])
  end
end
