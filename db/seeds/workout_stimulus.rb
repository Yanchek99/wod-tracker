# Intended stimulus for seeded workouts, derived from published coaching guidance.
# Values only: range is [low, high] in the workout's score unit (seconds for
# time, total reps for rep-scored AMRAPs, rounds for round-scored ones). Per-exercise values are
# keyed by movement name and apply to every occurrence of that movement; a movement whose
# occurrences differ lists one value per occurrence in workout order (nil leaves it unset).
# Rows a coach has authored are left alone.
{
  'Eva' => {
    range: [nil, 2700],
    exercises: {
      'Run' => { duration_max: 300 },
      'Kettlebell Swing' => { sets_max: 4 },
      'Pull-up' => { sets_max: 5 }
    }
  },
  'Angie' => {
    range: [840, 1200],
    exercises: {
      'Pull-up' => { duration_max: 360 },
      'Push-up' => { duration_max: 360 },
      'Sit-up' => { duration_max: 240 },
      'Air Squat' => { duration_max: 240 }
    }
  },
  'Nicole' => {
    range: [6, 7],
    exercises: {
      'Run' => { duration_max: 150 }
    }
  },
  'Amanda' => { range: [240, 600], exercises: {} },
  'Jackie' => {
    range: [480, 840],
    exercises: {
      'Row' => { duration_max: 300 },
      'Thruster' => { duration_max: 180 }
    }
  },
  'Barbara' => {
    range: [900, 1200],
    exercises: {
      'Pull-up' => { sets_max: 2 },
      'Push-up' => { sets_max: 4 }
    }
  },
  'Mary' => {
    range: [240, 300],
    exercises: {
      'Handstand Push-up' => { sets_max: 1 },
      'Pull-up' => { sets_max: 3 }
    }
  },
  'Isabel' => {
    range: [120, 480],
    exercises: {
      'Snatch' => { loading: :moderate }
    }
  },
  'Helen' => {
    range: [480, 900],
    exercises: {
      'Run' => { duration_max: 120 },
      'Kettlebell Swing' => { sets_max: 1 },
      'Pull-up' => { sets_max: 3 }
    }
  },
  'Karen' => { range: [240, 600], exercises: {} },
  'Abbate' => {
    range: [1260, 1800],
    exercises: {
      'Run' => [{ duration_max: 540 }, { duration_max: 300 }, { duration_max: 540 }],
      'Clean and Jerk' => { duration_max: 180 }
    }
  },
  'Open 25.3' => {
    range: [nil, nil],
    exercises: {
      'Wall Walk' => { duration_max: 120 },
      'Deadlift' => { duration_max: 180 },
      'Clean' => { duration_max: 180 },
      'Snatch' => { duration_max: 180 }
    }
  },
  'Grace' => {
    range: [120, 420],
    exercises: {
      'Clean and Jerk' => { loading: :moderate }
    }
  },
  'Annie' => { range: [nil, 600], exercises: {} },
  'Kelly' => {
    range: [nil, 1800],
    exercises: {
      'Run' => { duration_max: 135 }
    }
  },
  'Andi' => {
    range: [1200, 1500],
    exercises: {
      'Hang Power Snatch' => { loading: :light },
      'Push Press' => { loading: :light },
      'Sumo Deadlift High Pull' => { loading: :light },
      'Front Squat' => { loading: :light }
    }
  },
  'Nasty Girls' => {
    range: [540, 780],
    exercises: {
      'Air Squat' => { duration_max: 120 },
      'Muscle-up' => { sets_max: 3 },
      'Hang Power Clean' => { sets_max: 2, loading: :moderate }
    }
  },
  'Cindy' => { range: [300, 600], exercises: {} },
  'Adrian' => {
    range: [1080, 1380],
    exercises: {
      'Forward Roll' => { duration_max: 30 },
      'Wall Walk' => { duration_max: 90 },
      'Toes to Bar' => { sets_max: 1, duration_max: 30 },
      'Box Jump' => { duration_max: 45 }
    }
  },
  'Brian' => {
    range: [600, 900],
    exercises: {
      'Rope Climb' => { duration_max: 150 },
      'Back Squat' => { duration_max: 150, sets_max: 3, loading: :moderate }
    }
  },
  'CrossFit Total' => {
    range: [nil, nil],
    exercises: {
      'Back Squat' => { loading: :heavy, duration_max: 600 },
      'Shoulder Press' => { loading: :heavy, duration_max: 600 },
      'Deadlift' => { loading: :heavy, duration_max: 600 }
    }
  },
  'Nancy' => {
    range: [600, 1080],
    exercises: {
      'Overhead Squat' => { loading: :light }
    }
  },
  'Diane' => {
    range: [nil, 600],
    exercises: {
      'Deadlift' => { loading: :moderate }
    }
  },
  'Linda' => {
    range: [900, 1800],
    exercises: {
      'Deadlift' => { sets_max: 1 },
      'Bench Press' => { sets_max: 2 },
      'Clean' => { duration_max: 90 }
    }
  },
  'Holleyman' => {
    range: [nil, 1800],
    exercises: {
      'Power Clean' => { loading: :heavy }
    }
  },
  'Del' => {
    range: [960, 1500],
    exercises: {
      'Run' => { duration_max: 180 },
      'Weighted Pull-up' => { sets_max: 4 },
      'Handstand Push-up' => { sets_max: 4 },
      'Chest-to-bar Pull-up' => { sets_max: 4 }
    }
  },
  'DT' => {
    range: [300, 720],
    exercises: {
      'Deadlift' => { loading: :light },
      'Hang Power Clean' => { loading: :moderate },
      'Push Jerk' => { loading: :moderate, sets_max: 1 }
    }
  },
  'Jerry' => {
    range: [1260, 1680],
    exercises: {
      'Run' => { duration_max: 540 },
      'Row' => { duration_max: 600 }
    }
  },
  'Daniel' => {
    range: [660, 1200],
    exercises: {
      'Pull-up' => { duration_max: 180 },
      'Run' => [nil, { duration_max: 300 }, nil],
      'Thruster' => { sets_max: 3 }
    }
  },
  'Jack' => {
    range: [240, 600],
    exercises: {
      'Push Press' => { sets_max: 1 },
      'Kettlebell Swing' => { sets_max: 1 },
      'Box Jump' => { sets_max: 1 }
    }
  },
  'Jennifer' => {
    range: [315, 675],
    exercises: {
      'Kettlebell Swing' => { sets_max: 2 },
      'Box Jump' => { duration_max: 90 }
    }
  },
  'JT' => { range: [300, 720], exercises: {} },
  'Eva Strong' => {
    range: [900, 1500],
    exercises: {
      'Double-under' => { duration_max: 60 },
      'Toes to Bar' => { duration_max: 60 },
      'Clean and Jerk' => { duration_max: 60 },
      'Run' => { duration_max: 150 }
    }
  },
  'Jack\'s Triangle' => {
    range: [nil, nil],
    exercises: {
      'Deadlift' => { loading: :moderate },
      'Strict Pull-up' => { duration_max: 30 },
      'Box Jump' => { duration_max: 75 },
      'Hand-release Push-up' => { duration_max: 60 },
      'Air Bike' => { duration_max: 150 }
    }
  },
  'Manion' => {
    range: [nil, nil],
    exercises: {
      'Run' => { duration_max: 135 },
      'Back Squat' => { sets_max: 2, loading: :light }
    }
  },
  'Lumberjack 20' => {
    range: [1500, 2100],
    exercises: {
      'Deadlift' => { duration_max: 90, sets_max: 3 },
      'Run' => { duration_max: 150 },
      'Kettlebell Swing' => { duration_max: 90 },
      'Overhead Squat' => { duration_max: 90, sets_max: 3 },
      'Burpee' => { duration_max: 90 },
      'Chest-to-bar Pull-up' => { duration_max: 90 },
      'Box Jump' => { duration_max: 90 },
      'Dumbbell Squat Clean' => { duration_max: 90 }
    }
  },
  'Kelly Brown' => {
    range: [900, 1500],
    exercises: {
      'Row' => { duration_max: 135 }
    }
  },
  'Morrison' => { range: [1080, 1440], exercises: {} },
  'Loredo' => { range: [1200, 1800], exercises: {} },
  'Nate' => {
    range: [112, 210],
    exercises: {
      'Kettlebell Swing' => { sets_max: 1 }
    }
  },
  'Randy' => {
    range: [180, 600],
    exercises: {
      'Power Snatch' => { loading: :light }
    }
  },
  'Murph' => {
    range: [1800, 2700],
    exercises: {
      'Run' => { duration_max: 600 }
    }
  },
  'Laura' => {
    range: [240, 420],
    exercises: {
      'Row' => { duration_max: 180 },
      'Burpee Over Rower' => { duration_max: 90 },
      'Power Clean' => { duration_max: 60, loading: :moderate }
    }
  },
  'Omar' => {
    range: [420, 720],
    exercises: {
      'Thruster' => { loading: :light }
    }
  },
  'Michael' => {
    range: [1440, 1800],
    exercises: {
      'Run' => { duration_max: 330 },
      'Back Extensions' => { duration_max: 135 },
      'Sit-up' => { duration_max: 135 }
    }
  },
  'Ned' => {
    range: [1800, 2400],
    exercises: {
      'Back Squat' => { sets_max: 1, duration_max: 60 },
      'Row' => { duration_max: 270 }
    }
  },
  'The Seven' => {
    range: [1260, 1800],
    exercises: {
      'Handstand Push-up' => { sets_max: 1 },
      'Thruster' => { sets_max: 1 },
      'Knees-to-elbows' => { sets_max: 1 },
      'Deadlift' => { sets_max: 1 },
      'Burpee' => { sets_max: 1 },
      'Kettlebell Swing' => { sets_max: 1 },
      'Pull-up' => { sets_max: 1 }
    }
  },
  'Ryan' => {
    range: [900, 1200],
    exercises: {
      'Muscle-up' => { duration_max: 90 },
      'Burpee' => { duration_max: 120 }
    }
  },
  'Sham' => {
    range: [420, 660],
    exercises: {
      'Deadlift' => { sets_max: 2 },
      'Run' => { duration_max: 40 }
    }
  },
  'Open 15.3' => { range: [236, 314], exercises: {} },
  'Open 15.5' => {
    range: [420, 720],
    exercises: {
      'Thruster' => { loading: :light }
    }
  },
  'Open 11.4' => {
    range: [100, nil],
    exercises: {
      'Overhead Squat' => { sets_max: 4 }
    }
  },
  'Open 12.3' => {
    range: [216, 360],
    exercises: {
      'Box Jump' => { duration_max: 60 },
      'Push Press' => { sets_max: 2 },
      'Toes to Bar' => { sets_max: 3 }
    }
  },
  'Wyk' => {
    range: [1200, 1800],
    exercises: {
      'Front Squat' => { duration_max: 60 },
      'Rope Climb' => { duration_max: 120 },
      'Run' => { duration_max: 180 }
    }
  },
  'Open 13.2' => {
    range: [210, nil],
    exercises: {
      'Shoulder to Overhead' => { sets_max: 1, loading: :light },
      'Deadlift' => { sets_max: 1, loading: :light },
      'Box Jump' => { sets_max: 2 }
    }
  },
  'Open 11.3' => {
    range: [40, 40],
    exercises: {
      'Clean and Jerk' => { loading: :moderate }
    }
  },
  'Topsy' => {
    range: [168, 280],
    exercises: {
      'Ring Muscle-up' => { duration_max: 45 },
      'Thruster' => { duration_max: 60 },
      'Row' => { duration_max: 120 }
    }
  },
  'Partner Weston' => {
    range: [1920, 2400],
    exercises: {
      'Row' => { duration_max: 300 },
      'Dumbbell Farmers Carry' => { sets_max: 1 }
    }
  },
  'Open 22.2' => {
    range: [nil, nil],
    exercises: {
      'Deadlift' => { loading: :moderate }
    }
  },
  'Open 17.5' => {
    range: [600, 1200],
    exercises: {
      'Thruster' => { sets_max: 2 },
      'Double-under' => { duration_max: 40 }
    }
  },
  'Open 18.2' => { range: [300, 600], exercises: {} },
  'Open 11.6' => { range: [60, 90], exercises: {} },
  'Open 20.1' => {
    range: [240, 480],
    exercises: {
      'Ground to Overhead' => { duration_max: 40 },
      'Bar-facing Burpee' => { duration_max: 60 }
    }
  },
  'Open 22.1' => {
    range: [150, nil],
    exercises: {
      'Wall Walk' => { duration_max: 60 },
      'Dumbbell Power Snatch' => { duration_max: 60 },
      'Box Jump-over' => { duration_max: 60 }
    }
  },
  'Open 20.2' => {
    range: [340, 680],
    exercises: {
      'Dumbbell Thruster' => { sets_max: 1 },
      'Toes to Bar' => { sets_max: 3, duration_max: 30 },
      'Double-under' => { duration_max: 45 }
    }
  },
  'Open 24.2' => {
    range: [400, 720],
    exercises: {
      'Row' => { duration_max: 120 },
      'Double-under' => { duration_max: 60 }
    }
  },
  'Open 24.3' => {
    range: [420, 900],
    exercises: {
      'Thruster' => [{ loading: :light }, nil],
      'Chest-to-bar Pull-up' => { sets_max: 3 },
      'Bar Muscle-up' => { sets_max: 3 }
    }
  },
  'Open 24.1' => { range: [420, 900], exercises: {} },
  'Lynne' => { range: [100, nil], exercises: {} },
  'The Ghost' => { range: [440, nil], exercises: {} },
  'Open 15.4' => { range: [45, nil], exercises: {} },
  'Open 14.4' => { range: [150, nil], exercises: {} }
}.each do |name, stimulus|
  workout = Workout.find_by!(name:)
  next if workout.stimulus_source_authored?

  low, high = stimulus[:range]
  workout.update!(stimulus_range_low: low, stimulus_range_high: high,
                  stimulus_source: (low || high) && :extracted)
  stimulus[:exercises].each do |movement_name, values|
    exercises = workout.exercises.joins(:movement).where(movements: { name: movement_name })
                       .order('segments.position', :position).to_a
    values = Array.new(exercises.size, values) if values.is_a?(Hash)
    if exercises.empty? || values.size != exercises.size
      # An existing workout can drift from its seed definition (edited or re-resolved movements);
      # skip it rather than abort the whole seed run, which blocks deploys.
      warn "Skipping #{name}: #{movement_name} stimulus (#{exercises.size} occurrences, #{values.size} values)"
      next
    end

    exercises.zip(values).each do |exercise, value|
      next if value.nil? || exercise.stimulus_source_authored?

      exercise.update!(stimulus_loading: value[:loading], stimulus_sets_max: value[:sets_max],
                       stimulus_duration_max: value[:duration_max], stimulus_source: :extracted)
    end
  end
end
