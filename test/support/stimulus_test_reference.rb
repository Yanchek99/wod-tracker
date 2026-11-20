# A small, fixed reference table for calculator tests, so the drafted production table
# (config/stimulus_reference.yml) can change without breaking exact-number tests.
module StimulusTestReference
  CONSTANTS = {
    'transition_seconds' => 10, 'slow_factor' => 2, 'monostructural_slow_factor' => 1.5, 'heavy_boundary' => 0.85, 'female_reference_factor' => 0.7,
    'chunk_reps' => { 'light' => 15, 'moderate' => 7, 'heavy' => 2 },
    'effort_seconds' => { 'sprint' => 60, 'hard' => 180, 'threshold' => 600 },
    'heavy_rest_seconds' => [180, 300], 'heavy_working_percent_low' => 80, 'height_factor_range' => [0.5, 1.5]
  }.freeze

  private

  def test_reference
    StimulusReference.new(
      'constants' => CONSTANTS,
      'lift_families' => {
        'squat' => lift(205, 0.50, 2.0, 2.5, 4.0), 'hinge' => lift(425, 0.50, 1.5, 2.0, 5.0),
        'clean' => lift(255, 0.45, 4.0, 6.0, 12.0)
      },
      'implements' => { 'kettlebell' => { 'typical_load' => 53 },
                        'medicine_ball' => { 'typical_load' => 20, 'typical_height' => { 'value' => 10, 'unit' => 'foot' } } },
      'implement_loading' => { 'light_up_to' => 1.1, 'heavy_from' => 1.6 },
      'implement_paces' => { 'rep' => { 'light' => 2.0, 'moderate' => 2.5, 'heavy' => 3.5 } },
      'skill_levels' => { 'basic' => { 'paces' => { 'rep' => 1.2 } }, 'intermediate' => { 'paces' => { 'rep' => 1.5 } },
                          'advanced' => { 'paces' => { 'rep' => 3.0 } } },
      'typical_heights' => { 'box' => { 'value' => 24, 'unit' => 'inch' } },
      'monostructural' => { 'Run' => { 'paces' => { 'meter' => 0.25 } },
                            'Row' => { 'paces' => { 'meter' => 0.2, 'calorie' => 3.0 } } },
      'overrides' => { 'Rest' => { 'paces' => { 'second' => 1.0 } } }
    )
  end

  def lift(reference_load, light_below, light, moderate, heavy)
    { 'reference_load' => reference_load, 'light_below' => light_below,
      'paces' => { 'rep' => { 'light' => light, 'moderate' => moderate, 'heavy' => heavy } } }
  end

  # A persisted workout with one segment. movements: exercise attribute hashes.
  def build_workout(name, movements:, score_type: :time, **segment)
    workout = Workout.create!(name:, score_type:)
    seg = workout.segments.create!(position: 1, **segment)
    movements.each.with_index(1) { |attrs, position| seg.exercises.create!(position:, **attrs) }
    workout.reload
  end

  # A barbell deadlift with its taxonomy (the deadlift fixture has none, on purpose).
  def barbell_deadlift
    @barbell_deadlift ||= Movement.create!(name: 'Barbell Deadlift', family: :weightlifting, equipment: :barbell,
                                           function_roles: { primary: :hinge })
  end

  def fran
    build_workout('Fran Calc', interval_scheme: '21-15-9',
                               movements: [{ movement: movements(:thruster), reps: 1, male_load: 95, female_load: 65,
                                             load_unit: :lb },
                                           { movement: movements(:pullup), reps: 1 }])
  end
end
