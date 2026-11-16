# Intended stimulus for seeded workouts, derived from published coaching guidance.
# Values only: range is [low, high] in the workout's score unit (seconds for
# time, total reps for rep-scored AMRAPs, rounds for round-scored ones); per-exercise values are
# keyed by "segment_position.exercise_position". Rows a coach has authored are left alone.
{
  'Eva' => {
    range: [nil, 2700],
    exercises: {
      '1.1' => { duration_max: 300 },
      '1.2' => { sets_max: 4 },
      '1.3' => { sets_max: 5 }
    }
  },
  'Angie' => {
    range: [840, 1200],
    exercises: {
      '1.1' => { duration_max: 360 },
      '1.2' => { duration_max: 360 },
      '1.3' => { duration_max: 240 },
      '1.4' => { duration_max: 240 }
    }
  },
  'Nicole' => {
    range: [6, 7],
    exercises: {
      '1.1' => { duration_max: 150 }
    }
  },
  'Amanda' => { range: [240, 600], exercises: {} },
  'Jackie' => {
    range: [480, 840],
    exercises: {
      '1.1' => { duration_max: 300 },
      '1.2' => { duration_max: 180 }
    }
  },
  'Barbara' => {
    range: [900, 1200],
    exercises: {
      '1.1' => { sets_max: 2 },
      '1.2' => { sets_max: 4 }
    }
  },
  'Mary' => {
    range: [240, 300],
    exercises: {
      '1.1' => { sets_max: 1 },
      '1.3' => { sets_max: 3 }
    }
  },
  'Isabel' => {
    range: [120, 480],
    exercises: {
      '1.1' => { loading: :moderate }
    }
  },
  'Helen' => {
    range: [480, 900],
    exercises: {
      '1.1' => { duration_max: 120 },
      '1.2' => { sets_max: 1 },
      '1.3' => { sets_max: 3 }
    }
  },
  'Karen' => { range: [240, 600], exercises: {} },
  'Abbate' => {
    range: [1260, 1800],
    exercises: {
      '1.1' => { duration_max: 540 },
      '1.2' => { duration_max: 180 },
      '1.3' => { duration_max: 300 },
      '1.4' => { duration_max: 180 },
      '1.5' => { duration_max: 540 }
    }
  },
  'Open 25.3' => {
    range: [nil, nil],
    exercises: {
      '1.1' => { duration_max: 120 },
      '1.3' => { duration_max: 120 },
      '1.4' => { duration_max: 180 },
      '1.5' => { duration_max: 120 },
      '1.6' => { duration_max: 180 },
      '1.7' => { duration_max: 120 },
      '1.8' => { duration_max: 180 },
      '1.9' => { duration_max: 120 }
    }
  },
  'Grace' => {
    range: [120, 420],
    exercises: {
      '1.1' => { loading: :moderate }
    }
  },
  'Annie' => { range: [nil, 600], exercises: {} },
  'Kelly' => {
    range: [nil, 1800],
    exercises: {
      '1.1' => { duration_max: 135 }
    }
  },
  'Andi' => {
    range: [1200, 1500],
    exercises: {
      '1.1' => { loading: :light },
      '1.2' => { loading: :light },
      '1.3' => { loading: :light },
      '1.4' => { loading: :light }
    }
  },
  'Nasty Girls' => {
    range: [540, 780],
    exercises: {
      '1.1' => { duration_max: 120 },
      '1.2' => { sets_max: 3 },
      '1.3' => { sets_max: 2, loading: :moderate }
    }
  },
  'Cindy' => { range: [300, 600], exercises: {} },
  'Adrian' => {
    range: [1080, 1380],
    exercises: {
      '1.1' => { duration_max: 30 },
      '1.2' => { duration_max: 90 },
      '1.3' => { sets_max: 1, duration_max: 30 },
      '1.4' => { duration_max: 45 }
    }
  },
  'Brian' => {
    range: [600, 900],
    exercises: {
      '1.1' => { duration_max: 150 },
      '1.2' => { duration_max: 150, sets_max: 3, loading: :moderate }
    }
  },
  'CrossFit Total' => {
    range: [nil, nil],
    exercises: {
      '1.1' => { loading: :heavy, duration_max: 600 },
      '1.2' => { loading: :heavy, duration_max: 600 },
      '1.3' => { loading: :heavy, duration_max: 600 }
    }
  },
  'Nancy' => {
    range: [600, 1080],
    exercises: {
      '1.2' => { loading: :light }
    }
  },
  'Diane' => {
    range: [nil, 600],
    exercises: {
      '1.1' => { loading: :moderate }
    }
  },
  'Linda' => {
    range: [900, 1800],
    exercises: {
      '1.1' => { sets_max: 1 },
      '1.2' => { sets_max: 2 },
      '1.3' => { duration_max: 90 }
    }
  },
  'Holleyman' => {
    range: [nil, 1800],
    exercises: {
      '1.3' => { loading: :heavy }
    }
  },
  'Del' => {
    range: [960, 1500],
    exercises: {
      '1.2' => { duration_max: 180 },
      '1.3' => { sets_max: 4 },
      '1.4' => { duration_max: 180 },
      '1.5' => { sets_max: 4 },
      '1.6' => { duration_max: 180 },
      '1.7' => { sets_max: 4 },
      '1.8' => { duration_max: 180 }
    }
  },
  'DT' => {
    range: [300, 720],
    exercises: {
      '1.1' => { loading: :light },
      '1.2' => { loading: :moderate },
      '1.3' => { loading: :moderate, sets_max: 1 }
    }
  },
  'Jerry' => {
    range: [1260, 1680],
    exercises: {
      '1.1' => { duration_max: 540 },
      '1.2' => { duration_max: 600 },
      '1.3' => { duration_max: 540 }
    }
  },
  'Daniel' => {
    range: [660, 1200],
    exercises: {
      '1.1' => { duration_max: 180 },
      '1.3' => { sets_max: 3 },
      '1.4' => { duration_max: 300 },
      '1.5' => { sets_max: 3 },
      '1.7' => { duration_max: 180 }
    }
  },
  'Jack' => {
    range: [240, 600],
    exercises: {
      '1.1' => { sets_max: 1 },
      '1.2' => { sets_max: 1 },
      '1.3' => { sets_max: 1 }
    }
  },
  'Jennifer' => {
    range: [315, 675],
    exercises: {
      '1.2' => { sets_max: 2 },
      '1.3' => { duration_max: 90 }
    }
  },
  'JT' => { range: [300, 720], exercises: {} },
  'Eva Strong' => {
    range: [900, 1500],
    exercises: {
      '1.1' => { duration_max: 60 },
      '1.2' => { duration_max: 60 },
      '1.3' => { duration_max: 60 },
      '1.4' => { duration_max: 150 }
    }
  },
  'Jack\'s Triangle' => {
    range: [nil, nil],
    exercises: {
      '1.1' => { loading: :moderate },
      '2.1' => { duration_max: 30 },
      '2.2' => { duration_max: 75 },
      '2.3' => { duration_max: 60 },
      '2.4' => { duration_max: 150 },
      '3.1' => { loading: :moderate }
    }
  },
  'Manion' => {
    range: [nil, nil],
    exercises: {
      '1.1' => { duration_max: 135 },
      '1.2' => { sets_max: 2, loading: :light }
    }
  },
  'Lumberjack 20' => {
    range: [1500, 2100],
    exercises: {
      '1.1' => { duration_max: 90, sets_max: 3 },
      '1.2' => { duration_max: 150 },
      '1.3' => { duration_max: 90 },
      '1.4' => { duration_max: 150 },
      '1.5' => { duration_max: 90, sets_max: 3 },
      '1.6' => { duration_max: 150 },
      '1.7' => { duration_max: 90 },
      '1.8' => { duration_max: 150 },
      '1.9' => { duration_max: 90 },
      '1.10' => { duration_max: 150 },
      '1.11' => { duration_max: 90 },
      '1.12' => { duration_max: 150 },
      '1.13' => { duration_max: 90 },
      '1.14' => { duration_max: 150 }
    }
  },
  'Kelly Brown' => {
    range: [900, 1500],
    exercises: {
      '1.1' => { duration_max: 135 }
    }
  },
  'Morrison' => { range: [1080, 1440], exercises: {} },
  'Loredo' => { range: [1200, 1800], exercises: {} },
  'Nate' => {
    range: [112, 210],
    exercises: {
      '1.3' => { sets_max: 1 }
    }
  },
  'Randy' => {
    range: [180, 600],
    exercises: {
      '1.1' => { loading: :light }
    }
  },
  'Murph' => {
    range: [1800, 2700],
    exercises: {
      '1.1' => { duration_max: 600 },
      '1.5' => { duration_max: 600 }
    }
  },
  'Laura' => {
    range: [240, 420],
    exercises: {
      '1.1' => { duration_max: 180 },
      '1.2' => { duration_max: 90 },
      '1.3' => { duration_max: 60, loading: :moderate }
    }
  },
  'Omar' => {
    range: [420, 720],
    exercises: {
      '1.1' => { loading: :light },
      '1.3' => { loading: :light },
      '1.5' => { loading: :light }
    }
  },
  'Michael' => {
    range: [1440, 1800],
    exercises: {
      '1.1' => { duration_max: 330 },
      '1.2' => { duration_max: 135 },
      '1.3' => { duration_max: 135 }
    }
  },
  'Ned' => {
    range: [1800, 2400],
    exercises: {
      '1.1' => { sets_max: 1, duration_max: 60 },
      '1.2' => { duration_max: 270 }
    }
  },
  'The Seven' => {
    range: [1260, 1800],
    exercises: {
      '1.1' => { sets_max: 1 },
      '1.2' => { sets_max: 1 },
      '1.3' => { sets_max: 1 },
      '1.4' => { sets_max: 1 },
      '1.5' => { sets_max: 1 },
      '1.6' => { sets_max: 1 },
      '1.7' => { sets_max: 1 }
    }
  },
  'Ryan' => {
    range: [900, 1200],
    exercises: {
      '1.1' => { duration_max: 90 },
      '1.2' => { duration_max: 120 }
    }
  },
  'Sham' => {
    range: [420, 660],
    exercises: {
      '1.1' => { sets_max: 2 },
      '1.2' => { duration_max: 40 }
    }
  },
  'Open 15.3' => { range: [236, 314], exercises: {} },
  'Open 15.5' => {
    range: [420, 720],
    exercises: {
      '1.2' => { loading: :light }
    }
  },
  'Open 11.4' => {
    range: [nil, nil],
    exercises: {
      '1.2' => { sets_max: 4 }
    }
  },
  'Open 12.3' => {
    range: [216, 360],
    exercises: {
      '1.1' => { duration_max: 60 },
      '1.2' => { sets_max: 2 },
      '1.3' => { sets_max: 3 }
    }
  },
  'Wyk' => {
    range: [1200, 1800],
    exercises: {
      '1.1' => { duration_max: 60 },
      '1.2' => { duration_max: 120 },
      '1.3' => { duration_max: 180 }
    }
  },
  'Open 13.2' => {
    range: [nil, nil],
    exercises: {
      '1.1' => { sets_max: 1, loading: :light },
      '1.2' => { sets_max: 1, loading: :light },
      '1.3' => { sets_max: 2 }
    }
  },
  'Open 11.3' => {
    range: [40, 40],
    exercises: {
      '1.1' => { loading: :moderate }
    }
  },
  'Topsy' => {
    range: [168, 280],
    exercises: {
      '1.1' => { duration_max: 45 },
      '1.2' => { duration_max: 60 },
      '1.3' => { duration_max: 120 }
    }
  },
  'Partner Weston' => {
    range: [1920, 2400],
    exercises: {
      '1.1' => { duration_max: 300 },
      '1.2' => { sets_max: 1 }
    }
  },
  'Open 22.2' => {
    range: [nil, nil],
    exercises: {
      '1.1' => { loading: :moderate }
    }
  },
  'Open 17.5' => {
    range: [600, 1200],
    exercises: {
      '1.1' => { sets_max: 2 },
      '1.2' => { duration_max: 40 }
    }
  },
  'Open 18.2' => { range: [300, 600], exercises: {} },
  'Open 11.6' => { range: [60, 90], exercises: {} },
  'Open 20.1' => {
    range: [240, 480],
    exercises: {
      '1.1' => { duration_max: 40 },
      '1.2' => { duration_max: 60 }
    }
  },
  'Open 22.1' => {
    range: [nil, nil],
    exercises: {
      '1.1' => { duration_max: 60 },
      '1.2' => { duration_max: 60 },
      '1.3' => { duration_max: 60 }
    }
  },
  'Open 20.2' => {
    range: [340, 680],
    exercises: {
      '1.1' => { sets_max: 1 },
      '1.2' => { sets_max: 3, duration_max: 30 },
      '1.3' => { duration_max: 45 }
    }
  },
  'Open 24.2' => {
    range: [400, 720],
    exercises: {
      '1.1' => { duration_max: 120 },
      '1.3' => { duration_max: 60 }
    }
  },
  'Open 24.3' => {
    range: [420, 900],
    exercises: {
      '1.1' => { loading: :light },
      '1.2' => { sets_max: 3 },
      '3.2' => { sets_max: 3 }
    }
  },
  'Open 24.1' => { range: [420, 900], exercises: {} }
}.each do |name, stimulus|
  workout = Workout.find_by!(name:)
  next if workout.stimulus_source_authored?

  low, high = stimulus[:range]
  workout.update!(stimulus_range_low: low, stimulus_range_high: high,
                  stimulus_source: (low || high) && :extracted)
  stimulus[:exercises].each do |key, values|
    segment_position, exercise_position = key.split('.').map(&:to_i)
    exercise = workout.segments.find_by!(position: segment_position).exercises.find_by!(position: exercise_position)
    next if exercise.stimulus_source_authored?

    exercise.update!(stimulus_loading: values[:loading], stimulus_sets_max: values[:sets_max],
                     stimulus_duration_max: values[:duration_max], stimulus_source: :extracted)
  end
end
