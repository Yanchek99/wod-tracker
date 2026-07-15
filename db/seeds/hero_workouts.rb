# Hero Workouts
#
# Movements and structure come from https://www.crossfit.com/heroes. The index
# summaries omit most barbell loads and the per-workout detail pages are
# client-rendered (loads aren't in their fetchable HTML), so loads are taken
# from the official Hero Workouts PDF linked from that page. Every load and height
# that can attach to a movement is prescribed on the exercise (barbell/dumbbell/
# kettlebell/sandbag/plate/ruck loads, loaded carries and runs, box/rope-climb
# heights, and wall-ball target heights). Only what can't attach to a movement —
# a whole-workout weight vest, or a sandbag with no movement in the seeded
# workout — is kept as a workout note. Source-driven, not invented (see
# cf/docs/decisions.md).

# ==============================================================================
# Abbate
# For time: 1-mile run, 21 clean and jerks, 800-meter run, 21 clean and jerks, 1-mile run
Workout.find_or_create_by(name: 'Abbate') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 1600, distance_unit: :meter)
  segment.exercises.build(movement: clean_and_jerk, position: 2, reps: 21, female_load: 105, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: clean_and_jerk, position: 4, reps: 21, female_load: 105, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: run, position: 5, reps: 1, distance: 1600, distance_unit: :meter)
end

# ==============================================================================
# Adambrown
# 2 rounds for time: 24 deadlift, 24 box jump, 24 wall-ball, 24 bench press, 24 box jump, 24 wall-ball, 24 clean
Workout.find_or_create_by(name: 'Adambrown') do |workout|
  segment = workout.segments.build(rounds: 2, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: deadlift, position: 1, reps: 24, female_load: 95, male_load: 295, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 2, reps: 24, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: wall_ball_shot, position: 3, reps: 24, female_load: 14, male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: bench_press, position: 4, reps: 24, female_load: 135, male_load: 195, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 5, reps: 24, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: wall_ball_shot, position: 6, reps: 24, female_load: 14, male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: clean, position: 7, reps: 24, female_load: 95, male_load: 145, load_unit: :lb)
end

# ==============================================================================
# Adrian
# 7 rounds for time: 3 forward rolls, 5 wall climbs, 7 toes-to-bars, 9 box jumps
Workout.find_or_create_by(name: 'Adrian') do |workout|
  segment = workout.segments.build(rounds: 7, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: forward_roll, position: 1, reps: 3)
  segment.exercises.build(movement: wall_walk, position: 2, reps: 5)
  segment.exercises.build(movement: toes_to_bar, position: 3, reps: 7)
  segment.exercises.build(movement: box_jump, position: 4, reps: 9, female_distance: 24, male_distance: 30, distance_unit: :inch)
end

# ==============================================================================
# Alec
# For time: 3 rounds (8 burpees, 28 air squats, 9 push-ups); run 1,000m, 25 over-the-shoulder
# sandbag cleans, run 1,000m; 5 rounds (10 deadlifts, 14 box jumps, 10 burpees)
Workout.find_or_create_by(name: 'Alec') do |workout|
  workout.score_type = :time
  triplet = workout.segments.build(rounds: 3, position: 1)
  triplet.exercises.build(movement: burpee, position: 1, reps: 8)
  triplet.exercises.build(movement: air_squat, position: 2, reps: 28)
  triplet.exercises.build(movement: push_up, position: 3, reps: 9)
  middle = workout.segments.build(position: 2)
  middle.exercises.build(movement: run, position: 1, reps: 1, distance: 1000, distance_unit: :meter)
  middle.exercises.build(movement: sandbag_clean, position: 2, reps: 25, notes: 'Over the shoulder.', female_load: 75, male_load: 100, load_unit: :lb)
  middle.exercises.build(movement: run, position: 3, reps: 1, distance: 1000, distance_unit: :meter)
  finisher = workout.segments.build(rounds: 5, position: 5)
  finisher.exercises.build(movement: deadlift, position: 1, reps: 10, female_load: 155, male_load: 225, load_unit: :lb)
  finisher.exercises.build(movement: box_jump, position: 2, reps: 14, female_distance: 20, male_distance: 24, distance_unit: :inch)
  finisher.exercises.build(movement: burpee, position: 3, reps: 10)
end

# ==============================================================================
# Alexander
# 5 rounds for time: 31 back squats, 12 power cleans
Workout.find_or_create_by(name: 'Alexander') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: back_squat, position: 1, reps: 31, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: power_clean, position: 2, reps: 12, female_load: 125, male_load: 185, load_unit: :lb)
end

# ==============================================================================
# Andy
# For time: 25 thrusters, 50 box jumps, 75 deadlifts, 1.5-mile run, 75 deadlifts, 50 box jumps, 25 thrusters
Workout.find_or_create_by(name: 'Andy') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  workout.notes = 'Wear a 14-lb (♀) / 20-lb (♂) weight vest.'
  segment.exercises.build(movement: thruster, position: 1, reps: 25, female_load: 75, male_load: 115, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 2, reps: 50, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: deadlift, position: 3, reps: 75, female_load: 75, male_load: 115, load_unit: :lb)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 2400, distance_unit: :meter)
  segment.exercises.build(movement: deadlift, position: 5, reps: 75, female_load: 75, male_load: 115, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 6, reps: 50, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: thruster, position: 7, reps: 25, female_load: 75, male_load: 115, load_unit: :lb)
end

# ==============================================================================
# Arnie
# With a single kettlebell for time: 21 Turkish get-ups (R), 50 KB swings, 21 overhead squats (L),
# 50 KB swings, 21 overhead squats (R), 50 KB swings, 21 Turkish get-ups (L)
Workout.find_or_create_by(name: 'Arnie') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  workout.notes = 'Performed with a single kettlebell.'
  segment.exercises.build(movement: turkish_get_up, position: 1, reps: 21, notes: 'Right arm.', female_load: 53, male_load: 70, load_unit: :lb)
  segment.exercises.build(movement: kettlebell_swing, position: 2, reps: 50, female_load: 53, male_load: 70, load_unit: :lb)
  segment.exercises.build(movement: overhead_squat, position: 3, reps: 21, notes: 'Left arm.', female_load: 53, male_load: 70, load_unit: :lb)
  segment.exercises.build(movement: kettlebell_swing, position: 4, reps: 50, female_load: 53, male_load: 70, load_unit: :lb)
  segment.exercises.build(movement: overhead_squat, position: 5, reps: 21, notes: 'Right arm.', female_load: 53, male_load: 70, load_unit: :lb)
  segment.exercises.build(movement: kettlebell_swing, position: 6, reps: 50, female_load: 53, male_load: 70, load_unit: :lb)
  segment.exercises.build(movement: turkish_get_up, position: 7, reps: 21, notes: 'Left arm.', female_load: 53, male_load: 70, load_unit: :lb)
end

# ==============================================================================
# Artie
# AMRAP in 20 minutes: 5 pull-ups, 10 push-ups, 15 squats, 5 pull-ups, 10 thrusters
Workout.find_or_create_by(name: 'Artie') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: pull_up, position: 1, reps: 5)
  segment.exercises.build(movement: push_up, position: 2, reps: 10)
  segment.exercises.build(movement: air_squat, position: 3, reps: 15)
  segment.exercises.build(movement: pull_up, position: 4, reps: 5)
  segment.exercises.build(movement: thruster, position: 5, reps: 10, female_load: 65, male_load: 95, load_unit: :lb)
end

# ==============================================================================
# Badger
# 3 rounds for time: 30 squat cleans, 30 pull-ups, run 800 meters
Workout.find_or_create_by(name: 'Badger') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: clean_squat, position: 1, reps: 30, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 2, reps: 30)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 800, distance_unit: :meter)
end

# ==============================================================================
# Barraza
# AMRAP in 18 minutes: run 200m, 9 deadlifts, 6 burpee bar muscle-ups
Workout.find_or_create_by(name: 'Barraza') do |workout|
  segment = workout.segments.build(time_seconds: 1080, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 200, distance_unit: :meter)
  segment.exercises.build(movement: deadlift, position: 2, reps: 9, female_load: 185, male_load: 275, load_unit: :lb)
  segment.exercises.build(movement: burpee_bar_muscle_up, position: 3, reps: 6)
end

# ==============================================================================
# Bell
# 3 rounds for time: 21 deadlifts, 15 pull-ups, 9 front squats
Workout.find_or_create_by(name: 'Bell') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: deadlift, position: 1, reps: 21, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 2, reps: 15)
  segment.exercises.build(movement: front_squat, position: 3, reps: 9, female_load: 125, male_load: 185, load_unit: :lb)
end

# ==============================================================================
# Bert
# For time: 50 burpees, 400m run, 100 push-ups, 400m run, 150 walking lunges, 400m run,
# 200 squats, 400m run, 150 walking lunges, 400m run, 100 push-ups, 400m run, 50 burpees
Workout.find_or_create_by(name: 'Bert') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: burpee, position: 1, reps: 50)
  segment.exercises.build(movement: run, position: 2, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: push_up, position: 3, reps: 100)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: walking_lunge, position: 5, reps: 150)
  segment.exercises.build(movement: run, position: 6, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: air_squat, position: 7, reps: 200)
  segment.exercises.build(movement: run, position: 8, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: walking_lunge, position: 9, reps: 150)
  segment.exercises.build(movement: run, position: 10, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: push_up, position: 11, reps: 100)
  segment.exercises.build(movement: run, position: 12, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: burpee, position: 13, reps: 50)
end

# ==============================================================================
# Big Sexy
# 5 rounds for time: 6 deadlifts, 6 burpees, 5 cleans, 5 chest-to-bar pull-ups, 4 thrusters, 4 muscle-ups
Workout.find_or_create_by(name: 'Big Sexy') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: deadlift, position: 1, reps: 6, female_load: 205, male_load: 315, load_unit: :lb)
  segment.exercises.build(movement: burpee, position: 2, reps: 6)
  segment.exercises.build(movement: clean, position: 3, reps: 5, female_load: 155, male_load: 225, load_unit: :lb)
  segment.exercises.build(movement: chest_to_bar_pull_up, position: 4, reps: 5)
  segment.exercises.build(movement: thruster, position: 5, reps: 4, female_load: 105, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: muscle_up, position: 6, reps: 4)
end

# ==============================================================================
# Blake
# 4 rounds for time: 100-foot overhead walking lunge, 30 box jumps, 20 wall-ball shots, 10 handstand push-ups
Workout.find_or_create_by(name: 'Blake') do |workout|
  segment = workout.segments.build(rounds: 4, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: overhead_walking_lunge, position: 1, reps: 1, distance: 100, distance_unit: :foot, female_load: 25, male_load: 45,
                          load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 2, reps: 30, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: wall_ball_shot, position: 3, reps: 20, distance: 9, distance_unit: :foot, female_load: 14, male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: handstand_push_up, position: 4, reps: 10)
end

# ==============================================================================
# Bowen
# 3 rounds for time: 800m run, 7 deadlifts, 10 burpee pull-ups, 14 single-arm KB thrusters (7 each), 20 box jumps
Workout.find_or_create_by(name: 'Bowen') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: deadlift, position: 2, reps: 7, female_load: 185, male_load: 275, load_unit: :lb)
  segment.exercises.build(movement: burpee_pull_up, position: 3, reps: 10)
  segment.exercises.build(movement: kettlebell_thruster, position: 4, reps: 14, notes: 'Single arm, 7 each arm.', female_load: 35, male_load: 53,
                          load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 5, reps: 20, female_distance: 20, male_distance: 24, distance_unit: :inch)
end

# ==============================================================================
# Bradley
# 10 rounds for time: sprint 100m, 10 pull-ups, sprint 100m, 10 burpees, rest 30 seconds
Workout.find_or_create_by(name: 'Bradley') do |workout|
  segment = workout.segments.build(rounds: 10, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 100, distance_unit: :meter, notes: 'Sprint.')
  segment.exercises.build(movement: pull_up, position: 2, reps: 10)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 100, distance_unit: :meter, notes: 'Sprint.')
  segment.exercises.build(movement: burpee, position: 4, reps: 10)
  segment.exercises.build(movement: rest, position: 5, duration_seconds: 30)
end

# ==============================================================================
# Bradshaw
# 10 rounds for time: 3 handstand push-ups, 6 deadlifts, 12 pull-ups, 24 double-unders
Workout.find_or_create_by(name: 'Bradshaw') do |workout|
  segment = workout.segments.build(rounds: 10, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: handstand_push_up, position: 1, reps: 3)
  segment.exercises.build(movement: deadlift, position: 2, reps: 6, female_load: 155, male_load: 225, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 3, reps: 12)
  segment.exercises.build(movement: double_under, position: 4, reps: 24)
end

# ==============================================================================
# Brehm
# For time: 10 rope climbs to 15 feet, 20 back squats, 30 handstand push-ups, 40-calorie row
Workout.find_or_create_by(name: 'Brehm') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: rope_climb, position: 1, reps: 10, distance: 15, distance_unit: :foot)
  segment.exercises.build(movement: back_squat, position: 2, reps: 20, female_load: 155, male_load: 225, load_unit: :lb)
  segment.exercises.build(movement: handstand_push_up, position: 3, reps: 30)
  segment.exercises.build(movement: row, position: 4, reps: 1, calories: 40)
end

# ==============================================================================
# Brenton
# 5 rounds for time: 100-foot bear crawl, 100-foot broad jump. 3 burpees after every 5 broad jumps.
Workout.find_or_create_by(name: 'Brenton') do |workout|
  workout.score_type = :time
  main = workout.segments.build(rounds: 5, position: 1)
  main.exercises.build(movement: bear_crawl, position: 1, reps: 1, distance: 100, distance_unit: :foot)
  main.exercises.build(movement: broad_jump, position: 2, reps: 1, distance: 100, distance_unit: :foot)
  penalty = workout.segments.build(position: 3, name: 'After every 5 broad jumps')
  penalty.exercises.build(movement: burpee, position: 1, reps: 3)
end

# ==============================================================================
# Brian
# 3 rounds for time: 5 rope climbs to 15 feet, 25 back squats
Workout.find_or_create_by(name: 'Brian') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: rope_climb, position: 1, reps: 5, distance: 15, distance_unit: :foot)
  segment.exercises.build(movement: back_squat, position: 2, reps: 25, female_load: 125, male_load: 185, load_unit: :lb)
end

# ==============================================================================
# Bruck
# 4 rounds for time: 400m run, 24 back squats, 24 jerks
Workout.find_or_create_by(name: 'Bruck') do |workout|
  segment = workout.segments.build(rounds: 4, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: back_squat, position: 2, reps: 24, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: jerk, position: 3, reps: 24, female_load: 95, male_load: 135, load_unit: :lb)
end

# ==============================================================================
# Bulger
# 10 rounds for time: 150m run, 7 chest-to-bar pull-ups, 7 front squats, 7 handstand push-ups
Workout.find_or_create_by(name: 'Bulger') do |workout|
  segment = workout.segments.build(rounds: 10, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 150, distance_unit: :meter)
  segment.exercises.build(movement: chest_to_bar_pull_up, position: 2, reps: 7)
  segment.exercises.build(movement: front_squat, position: 3, reps: 7, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: handstand_push_up, position: 4, reps: 7)
end

# ==============================================================================
# Bull
# 2 rounds for time: 200 double-unders, 50 overhead squats, 50 pull-ups, 1-mile run
Workout.find_or_create_by(name: 'Bull') do |workout|
  segment = workout.segments.build(rounds: 2, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: double_under, position: 1, reps: 200)
  segment.exercises.build(movement: overhead_squat, position: 2, reps: 50, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 3, reps: 50)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 1600, distance_unit: :meter)
end

# ==============================================================================
# Buriak
# AMRAP in 20 minutes: 5 squat cleans, 10 burpees over the bar, 15 pull-ups, 200m run
Workout.find_or_create_by(name: 'Buriak') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: clean_squat, position: 1, reps: 5, female_load: 135, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: over_the_bar_burpee, position: 2, reps: 10)
  segment.exercises.build(movement: pull_up, position: 3, reps: 15)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 200, distance_unit: :meter)
end

# ==============================================================================
# Cameron
# For time: 50 walking lunge steps, 25 chest-to-bar pull-ups, 50 box jumps, 25 triple-unders,
# 50 back extensions, 25 ring dips, 50 knees-to-elbows, 25 wall-ball two-for-ones, 50 sit-ups,
# 5 rope climbs to 15 feet
Workout.find_or_create_by(name: 'Cameron') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: walking_lunge, position: 1, reps: 50)
  segment.exercises.build(movement: chest_to_bar_pull_up, position: 2, reps: 25)
  segment.exercises.build(movement: box_jump, position: 3, reps: 50, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: triple_under, position: 4, reps: 25)
  segment.exercises.build(movement: back_extensions, position: 5, reps: 50)
  segment.exercises.build(movement: ring_dip, position: 6, reps: 25)
  segment.exercises.build(movement: knees_to_elbows, position: 7, reps: 50)
  segment.exercises.build(movement: wall_ball_two_for_one, position: 8, reps: 25, distance: 9, distance_unit: :foot, female_load: 14, male_load: 20,
                          load_unit: :lb)
  segment.exercises.build(movement: sit_up, position: 9, reps: 50)
  segment.exercises.build(movement: rope_climb, position: 10, reps: 5, distance: 15, distance_unit: :foot)
end

# ==============================================================================
# Capoot
# For time: 100 push-ups, run 800m, 75 push-ups, run 1,200m, 50 push-ups, run 1,600m, 25 push-ups, run 2,000m
Workout.find_or_create_by(name: 'Capoot') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: push_up, position: 1, reps: 100)
  segment.exercises.build(movement: run, position: 2, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: push_up, position: 3, reps: 75)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 1200, distance_unit: :meter)
  segment.exercises.build(movement: push_up, position: 5, reps: 50)
  segment.exercises.build(movement: run, position: 6, reps: 1, distance: 1600, distance_unit: :meter)
  segment.exercises.build(movement: push_up, position: 7, reps: 25)
  segment.exercises.build(movement: run, position: 8, reps: 1, distance: 2000, distance_unit: :meter)
end

# ==============================================================================
# Carse
# 21-18-15-12-9-6-3 reps for time: squat cleans, double-unders, deadlifts, box jumps.
# Begin each round with a 50-meter bear crawl.
Workout.find_or_create_by(name: 'Carse') do |workout|
  segment = workout.segments.build(interval_scheme: '21-18-15-12-9-6-3', position: 1)
  workout.score_type = :time
  workout.notes = 'Begin each round with a 50-meter bear crawl.'
  segment.exercises.build(movement: clean_squat, position: 1, reps: 1, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: double_under, position: 2, reps: 1)
  segment.exercises.build(movement: deadlift, position: 3, reps: 1, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 4, reps: 1, female_distance: 20, male_distance: 24, distance_unit: :inch)
end

# ==============================================================================
# CHAD1000x
# For time: 1,000 weighted box step-ups
Workout.find_or_create_by(name: 'CHAD1000x') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  workout.notes = 'Performed with a weighted ruck or vest.'
  segment.exercises.build(movement: box_step_up, position: 1, reps: 1000, notes: 'Weighted.', female_distance: 20, male_distance: 20, distance_unit: :inch,
                          female_load: 35, male_load: 45, load_unit: :lb)
end

# ==============================================================================
# City 100
# For time with a partner: 31 shuttle runs (7 meters down, 7 meters back); then
# 10 rounds of 7 deadlifts, 7 hang power cleans, 7-meter overhead walking lunge
# (105/155 lb). One partner holds the barbell in the front rack while the other
# completes a full round, then they switch stations.
Workout.find_or_create_by(name: 'City 100') do |workout|
  workout.score_type = :time
  workout.team_size = 2
  workout.notes = 'With a partner. One partner holds the barbell in the front rack while the other ' \
                  'completes a full round of the complex, then switch stations.'
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: shuttle_run, position: 1, reps: 31, notes: '7 meters down, 7 meters back.')
  complex = workout.segments.build(rounds: 10, position: 2)
  complex.exercises.build(movement: deadlift, position: 1, reps: 7, female_load: 105, male_load: 155, load_unit: :lb)
  complex.exercises.build(movement: hang_power_clean, position: 2, reps: 7, female_load: 105, male_load: 155, load_unit: :lb)
  complex.exercises.build(movement: overhead_walking_lunge, position: 3, reps: 1, distance: 7, distance_unit: :meter, female_load: 105, male_load: 155,
                          load_unit: :lb)
end

# ==============================================================================
# Clovis
# For time: run 10 miles, 150 burpee pull-ups. Partition as needed.
Workout.find_or_create_by(name: 'Clovis') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  workout.notes = 'Partition the run and burpee pull-ups as needed.'
  # rubocop:disable Style/NumericLiterals -- Preserve the original seed literal.
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 16000, distance_unit: :meter)
  # rubocop:enable Style/NumericLiterals
  segment.exercises.build(movement: burpee_pull_up, position: 2, reps: 150)
end

# ==============================================================================
# Coe
# 10 rounds for time: 10 thrusters, 10 ring push-ups
Workout.find_or_create_by(name: 'Coe') do |workout|
  segment = workout.segments.build(rounds: 10, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: thruster, position: 1, reps: 10, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: ring_push_up, position: 2, reps: 10)
end

# ==============================================================================
# Coffey
# For time: 800m run, 50 back squats, 50 bench presses, 800m run, 35 back squats, 35 bench presses,
# 800m run, 20 back squats, 20 bench presses, 800m run, 1 muscle-up
Workout.find_or_create_by(name: 'Coffey') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: back_squat, position: 2, reps: 50, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: bench_press, position: 3, reps: 50, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: back_squat, position: 5, reps: 35, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: bench_press, position: 6, reps: 35, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: run, position: 7, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: back_squat, position: 8, reps: 20, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: bench_press, position: 9, reps: 20, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: run, position: 10, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: muscle_up, position: 11, reps: 1)
end

# ==============================================================================
# Coffland
# Hang from a pull-up bar for 6 minutes. Each time you drop, complete 800m run and 30 push-ups.
Workout.find_or_create_by(name: 'Coffland') do |workout|
  workout.score_type = :time
  workout.notes = 'Accumulate a total of 6 minutes hanging from a pull-up bar.'
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: bar_hang, position: 1, duration_seconds: 360)
  penalty = workout.segments.build(position: 2, name: 'Each time you drop from the bar')
  penalty.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  penalty.exercises.build(movement: push_up, position: 2, reps: 30)
end

# ==============================================================================
# Collin
# 6 rounds for time: 400m sandbag carry, 12 push presses, 12 box jumps, 12 sumo deadlift high pulls
Workout.find_or_create_by(name: 'Collin') do |workout|
  segment = workout.segments.build(rounds: 6, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: sandbag_carry, position: 1, reps: 1, distance: 400, distance_unit: :meter, female_load: 35, male_load: 50, load_unit: :lb)
  segment.exercises.build(movement: push_press, position: 2, reps: 12, female_load: 75, male_load: 115, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 3, reps: 12, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: sumo_deadlift_high_pull, position: 4, reps: 12, female_load: 65, male_load: 95, load_unit: :lb)
end

# ==============================================================================
# Crain
# 2 rounds for time: 34 push-ups, 50-yd sprint, 34 deadlifts, 50-yd sprint, 34 box jumps, 50-yd sprint,
# 34 clean and jerks, 50-yd sprint, 34 burpees, 50-yd sprint, 34 wall-ball shots, 50-yd sprint, 34 pull-ups, 50-yd sprint
Workout.find_or_create_by(name: 'Crain') do |workout|
  segment = workout.segments.build(rounds: 2, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: push_up, position: 1, reps: 34)
  segment.exercises.build(movement: run, position: 2, reps: 1, distance: 150, distance_unit: :foot, notes: '50-yard sprint.')
  segment.exercises.build(movement: deadlift, position: 3, reps: 34, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 150, distance_unit: :foot, notes: '50-yard sprint.')
  segment.exercises.build(movement: box_jump, position: 5, reps: 34, female_distance: 24, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: run, position: 6, reps: 1, distance: 150, distance_unit: :foot, notes: '50-yard sprint.')
  segment.exercises.build(movement: clean_and_jerk, position: 7, reps: 34, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: run, position: 8, reps: 1, distance: 150, distance_unit: :foot, notes: '50-yard sprint.')
  segment.exercises.build(movement: burpee, position: 9, reps: 34)
  segment.exercises.build(movement: run, position: 10, reps: 1, distance: 150, distance_unit: :foot, notes: '50-yard sprint.')
  segment.exercises.build(movement: wall_ball_shot, position: 11, reps: 34, distance: 9, distance_unit: :foot, female_load: 14, male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: run, position: 12, reps: 1, distance: 150, distance_unit: :foot, notes: '50-yard sprint.')
  segment.exercises.build(movement: pull_up, position: 13, reps: 34)
  segment.exercises.build(movement: run, position: 14, reps: 1, distance: 150, distance_unit: :foot, notes: '50-yard sprint.')
end

# ==============================================================================
# Dragon
# For max load: 4 minutes to find a 4-rep-max deadlift, then 4 minutes to find a
# 4-rep-max push jerk.
Workout.find_or_create_by(name: 'Dragon') do |workout|
  workout.score_type = :weight
  workout.notes = 'Post loads for both lifts.'
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: deadlift, position: 1, reps: 4, duration_seconds: 240, load_unit: :lb)
  segment.exercises.build(movement: push_jerk, position: 2, reps: 4, duration_seconds: 240, load_unit: :lb)
end

# ==============================================================================
# Dae Han
# 3 rounds for time: run 800m with an empty barbell, 3 rope climbs, 12 thrusters
Workout.find_or_create_by(name: 'Dae Han') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter, notes: 'Carry an empty barbell.', female_load: 35,
                          male_load: 45, load_unit: :lb)
  segment.exercises.build(movement: rope_climb, position: 2, reps: 3, distance: 15, distance_unit: :foot)
  segment.exercises.build(movement: thruster, position: 3, reps: 12, female_load: 95, male_load: 135, load_unit: :lb)
end

# ==============================================================================
# Dallas 5
# Five 5-minute stations (rest 1 min between), for total reps: max burpees; 7 deadlifts + 7 box jumps;
# max Turkish get-ups; 7 snatches + 7 push-ups; max-calorie row
Workout.find_or_create_by(name: 'Dallas 5') do |workout|
  workout.score_type = :rep
  workout.notes = 'Complete as many reps as possible at each 5-minute station. Rest 1 minute between stations.'
  station_one = workout.segments.build(position: 1, name: 'Station 1: burpees', time_seconds: 300)
  station_one.exercises.build(movement: burpee, position: 1, reps: 0)
  station_two = workout.segments.build(position: 2, name: 'Station 2', time_seconds: 300)
  station_two.exercises.build(movement: deadlift, position: 1, reps: 7, female_load: 105, male_load: 155, load_unit: :lb)
  station_two.exercises.build(movement: box_jump, position: 2, reps: 7, female_distance: 20, male_distance: 24, distance_unit: :inch)
  station_three = workout.segments.build(position: 3, name: 'Station 3: Turkish get-ups', time_seconds: 300)
  station_three.exercises.build(movement: turkish_get_up, position: 1, reps: 0, female_load: 30, male_load: 40, load_unit: :lb)
  station_four = workout.segments.build(position: 4, name: 'Station 4', time_seconds: 300)
  station_four.exercises.build(movement: snatch, position: 1, reps: 7, female_load: 55, male_load: 75, load_unit: :lb)
  station_four.exercises.build(movement: push_up, position: 2, reps: 7)
  station_five = workout.segments.build(position: 5, name: 'Station 5: row for calories', time_seconds: 300)
  station_five.exercises.build(movement: row, position: 1, reps: 1, calories: 0)
end

# ==============================================================================
# Daniel
# For time: 50 pull-ups, 400m run, 21 thrusters, 800m run, 21 thrusters, 400m run, 50 pull-ups
Workout.find_or_create_by(name: 'Daniel') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: pull_up, position: 1, reps: 50)
  segment.exercises.build(movement: run, position: 2, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: thruster, position: 3, reps: 21, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: thruster, position: 5, reps: 21, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: run, position: 6, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: pull_up, position: 7, reps: 50)
end

# ==============================================================================
# Daniel Ray
# 5 rounds for time: 25-ft double-KB front-rack lunge, 9 strict pull-ups, 50-ft double-KB overhead carry,
# 16 hand-release push-ups, 75-ft double-KB front-rack carry, 23 air squats, 100-ft double-KB farmers carry, 400m run
Workout.find_or_create_by(name: 'Daniel Ray') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  workout.notes = 'If you have a weight vest or body armor, wear it. All carries use two kettlebells.'
  segment.exercises.build(movement: dumbbell_front_rack_lunge, position: 1, reps: 1, distance: 25, distance_unit: :foot,
                          notes: 'Double kettlebell, front rack.', female_load: 35, male_load: 53, load_unit: :lb, implement_count: 2)
  segment.exercises.build(movement: strict_pull_up, position: 2, reps: 9)
  segment.exercises.build(movement: overhead_walk, position: 3, reps: 1, distance: 50, distance_unit: :foot, notes: 'Double kettlebell.', female_load: 35,
                          male_load: 53, load_unit: :lb)
  segment.exercises.build(movement: hand_release_push_up, position: 4, reps: 16)
  segment.exercises.build(movement: farmers_carry, position: 5, reps: 1, distance: 75, distance_unit: :foot, notes: 'Double kettlebell, front rack.',
                          female_load: 35, male_load: 53, load_unit: :lb)
  segment.exercises.build(movement: air_squat, position: 6, reps: 23)
  segment.exercises.build(movement: farmers_carry, position: 7, reps: 1, distance: 100, distance_unit: :foot, notes: 'Double kettlebell.', female_load: 35,
                          male_load: 53, load_unit: :lb)
  segment.exercises.build(movement: run, position: 8, reps: 1, distance: 400, distance_unit: :meter)
end

# ==============================================================================
# Danny
# AMRAP in 20 minutes: 30 box jumps, 20 push presses, 30 pull-ups
Workout.find_or_create_by(name: 'Danny') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: box_jump, position: 1, reps: 30, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: push_press, position: 2, reps: 20, female_load: 75, male_load: 115, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 3, reps: 30)
end

# ==============================================================================
# Del
# For time: 25 burpees, 400m run w/ med ball, 25 weighted pull-ups w/ dumbbell, 400m run w/ med ball,
# 25 handstand push-ups, 400m run w/ med ball, 25 chest-to-bar pull-ups, 400m run w/ med ball, 25 burpees
Workout.find_or_create_by(name: 'Del') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: burpee, position: 1, reps: 25)
  segment.exercises.build(movement: run, position: 2, reps: 1, distance: 400, distance_unit: :meter, notes: 'Carry a medicine ball.', female_load: 14,
                          male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: weighted_pull_up, position: 3, reps: 25, notes: 'Holding a dumbbell.', female_load: 15, male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 400, distance_unit: :meter, notes: 'Carry a medicine ball.', female_load: 14,
                          male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: handstand_push_up, position: 5, reps: 25)
  segment.exercises.build(movement: run, position: 6, reps: 1, distance: 400, distance_unit: :meter, notes: 'Carry a medicine ball.', female_load: 14,
                          male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: chest_to_bar_pull_up, position: 7, reps: 25)
  segment.exercises.build(movement: run, position: 8, reps: 1, distance: 400, distance_unit: :meter, notes: 'Carry a medicine ball.', female_load: 14,
                          male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: burpee, position: 9, reps: 25)
end

# ==============================================================================
# Desforges
# 5 rounds for time: 12 deadlifts, 20 pull-ups, 12 clean and jerks, 20 knees-to-elbows
Workout.find_or_create_by(name: 'Desforges') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: deadlift, position: 1, reps: 12, female_load: 155, male_load: 225, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 2, reps: 20)
  segment.exercises.build(movement: clean_and_jerk, position: 3, reps: 12, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: knees_to_elbows, position: 4, reps: 20)
end

# ==============================================================================
# DG
# AMRAP in 10 minutes: 8 toes-to-bars, 8 dumbbell thrusters, 12 dumbbell walking lunges
Workout.find_or_create_by(name: 'DG') do |workout|
  segment = workout.segments.build(time_seconds: 600, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: toes_to_bar, position: 1, reps: 8)
  segment.exercises.build(movement: dumbbell_thruster, position: 2, reps: 8, female_load: 20, male_load: 35, load_unit: :lb, implement_count: 2)
  segment.exercises.build(movement: walking_lunge, position: 3, reps: 12, notes: 'Holding dumbbells.', female_load: 20, male_load: 35, load_unit: :lb)
end

# ==============================================================================
# Dobogai
# 7 rounds for time: 8 muscle-ups, 22-yard farmers carry
Workout.find_or_create_by(name: 'Dobogai') do |workout|
  segment = workout.segments.build(rounds: 7, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: muscle_up, position: 1, reps: 8)
  segment.exercises.build(movement: farmers_carry, position: 2, reps: 1, distance: 66, distance_unit: :foot, notes: '22-yard carry.', female_load: 35,
                          male_load: 50, load_unit: :lb)
end

# ==============================================================================
# Dominic J. Hall
# Running clock. 0:00-12:23 max-rep box step-ups; 12:23-15:00 rest;
# 15:00-48:00 AMRAP: 9 deadlifts, 400m run, 22 push-ups
Workout.find_or_create_by(name: 'Dominic J. Hall') do |workout|
  workout.score_type = :rep
  workout.notes = 'Running clock. Rest from 12:23 to 15:00. Wear a 14-lb (♀) / 20-lb (♂) weight vest.'
  step = workout.segments.build(position: 1, name: '0:00-12:23', time_seconds: 743)
  step.exercises.build(movement: box_step_up, position: 1, reps: 0, female_distance: 20, male_distance: 20, distance_unit: :inch)
  amrap = workout.segments.build(position: 2, name: '15:00-48:00', time_seconds: 1980)
  amrap.exercises.build(movement: deadlift, position: 1, reps: 9, female_load: 185, male_load: 275, load_unit: :lb)
  amrap.exercises.build(movement: run, position: 2, reps: 1, distance: 400, distance_unit: :meter)
  amrap.exercises.build(movement: push_up, position: 3, reps: 22)
end

# ==============================================================================
# Donny
# 21-15-9-9-15-21 reps for time: deadlifts, burpees
Workout.find_or_create_by(name: 'Donny') do |workout|
  segment = workout.segments.build(interval_scheme: '21-15-9-9-15-21', position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: deadlift, position: 1, reps: 1, female_load: 155, male_load: 225, load_unit: :lb)
  segment.exercises.build(movement: burpee, position: 2, reps: 1)
end

# ==============================================================================
# Dork
# 6 rounds for time: 60 double-unders, 30 kettlebell swings, 15 burpees
Workout.find_or_create_by(name: 'Dork') do |workout|
  segment = workout.segments.build(rounds: 6, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: double_under, position: 1, reps: 60)
  segment.exercises.build(movement: kettlebell_swing, position: 2, reps: 30, female_load: 35, male_load: 53, load_unit: :lb)
  segment.exercises.build(movement: burpee, position: 3, reps: 15)
end

# ==============================================================================
# Drew
# For time (each round honors a fallen hero): Kraus, Scott, Good, Cully each with a run, pull-ups,
# hand-release push-ups, 4 deadlifts and a 30-second rest, then Night Stalkers: 269 step-ups
Workout.find_or_create_by(name: 'Drew') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 200, distance_unit: :meter, notes: 'Kraus.')
  segment.exercises.build(movement: pull_up, position: 2, reps: 30)
  segment.exercises.build(movement: hand_release_push_up, position: 3, reps: 30)
  segment.exercises.build(movement: deadlift, position: 4, reps: 4)
  segment.exercises.build(movement: rest, position: 5, duration_seconds: 30)
  segment.exercises.build(movement: run, position: 6, reps: 1, distance: 400, distance_unit: :meter, notes: 'Scott.')
  segment.exercises.build(movement: pull_up, position: 7, reps: 25)
  segment.exercises.build(movement: hand_release_push_up, position: 8, reps: 25)
  segment.exercises.build(movement: deadlift, position: 9, reps: 4)
  segment.exercises.build(movement: rest, position: 10, duration_seconds: 30)
  segment.exercises.build(movement: run, position: 11, reps: 1, distance: 600, distance_unit: :meter, notes: 'Good.')
  segment.exercises.build(movement: pull_up, position: 12, reps: 20)
  segment.exercises.build(movement: hand_release_push_up, position: 13, reps: 20)
  segment.exercises.build(movement: deadlift, position: 14, reps: 4)
  segment.exercises.build(movement: rest, position: 15, duration_seconds: 30)
  segment.exercises.build(movement: run, position: 16, reps: 1, distance: 800, distance_unit: :meter, notes: 'Cully.')
  segment.exercises.build(movement: pull_up, position: 17, reps: 15)
  segment.exercises.build(movement: hand_release_push_up, position: 18, reps: 15)
  segment.exercises.build(movement: deadlift, position: 19, reps: 4)
  segment.exercises.build(movement: rest, position: 20, duration_seconds: 30)
  segment.exercises.build(movement: box_step_up, position: 21, reps: 269, notes: 'Night Stalkers.')
end

# ==============================================================================
# DT
# 5 rounds for time: 12 deadlifts, 9 hang power cleans, 6 push jerks
Workout.find_or_create_by(name: 'DT') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: deadlift, position: 1, reps: 12, female_load: 105, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: hang_power_clean, position: 2, reps: 9, female_load: 105, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: push_jerk, position: 3, reps: 6, female_load: 105, male_load: 155, load_unit: :lb)
end

# ==============================================================================
# Dunn
# AMRAP in 19 minutes: 3 muscle-ups, 1 shuttle sprint (5/10/15 yds), 6 burpee box jump-overs
Workout.find_or_create_by(name: 'Dunn') do |workout|
  segment = workout.segments.build(time_seconds: 1140, position: 1)
  workout.score_type = :rep
  workout.notes = 'On the burpees, jump over the box without touching it.'
  segment.exercises.build(movement: muscle_up, position: 1, reps: 3)
  segment.exercises.build(movement: shuttle_run, position: 2, reps: 1, notes: '5 yards, 10 yards, 15 yards.')
  segment.exercises.build(movement: burpee_box_jump_over, position: 3, reps: 6, female_distance: 20, male_distance: 20, distance_unit: :inch)
end

# ==============================================================================
# DVB
# For time: 1-mile run w/ med ball; 8 rounds (10 wall-ball shots, 1 rope climb); 800m run w/ med ball;
# 4 rounds (10 wall-ball shots, 1 rope climb); 400m run w/ med ball; 2 rounds (10 wall-ball shots, 1 rope climb)
Workout.find_or_create_by(name: 'DVB') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 1600, distance_unit: :meter, notes: 'Carry a medicine ball.', female_load: 14,
                          male_load: 20, load_unit: :lb)
  round_eight = workout.segments.build(rounds: 8, position: 2)
  round_eight.exercises.build(movement: wall_ball_shot, position: 1, reps: 10, female_load: 14, male_load: 20, load_unit: :lb)
  round_eight.exercises.build(movement: rope_climb, position: 2, reps: 1)
  segment = workout.segments.build(position: 3)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter, notes: 'Carry a medicine ball.', female_load: 14,
                          male_load: 20, load_unit: :lb)
  round_four = workout.segments.build(rounds: 4, position: 4)
  round_four.exercises.build(movement: wall_ball_shot, position: 1, reps: 10, female_load: 14, male_load: 20, load_unit: :lb)
  round_four.exercises.build(movement: rope_climb, position: 2, reps: 1)
  segment = workout.segments.build(position: 5)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter, notes: 'Carry a medicine ball.', female_load: 14,
                          male_load: 20, load_unit: :lb)
  round_two = workout.segments.build(rounds: 2, position: 6)
  round_two.exercises.build(movement: wall_ball_shot, position: 1, reps: 10, female_load: 14, male_load: 20, load_unit: :lb)
  round_two.exercises.build(movement: rope_climb, position: 2, reps: 1)
end

# ==============================================================================
# Emily
# 10 rounds for time: 30 double-unders, 15 pull-ups, 30 squats, 100m sprint. Rest 2 minutes.
Workout.find_or_create_by(name: 'Emily') do |workout|
  segment = workout.segments.build(rounds: 10, position: 1)
  workout.score_type = :time
  workout.notes = 'Rest 2 minutes between rounds.'
  segment.exercises.build(movement: double_under, position: 1, reps: 30)
  segment.exercises.build(movement: pull_up, position: 2, reps: 15)
  segment.exercises.build(movement: air_squat, position: 3, reps: 30)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 100, distance_unit: :meter, notes: 'Sprint.')
end

# ==============================================================================
# Erin
# 5 rounds for time: 15 dumbbell split cleans, 21 pull-ups
Workout.find_or_create_by(name: 'Erin') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: dumbbell_split_clean, position: 1, reps: 15, female_load: 30, male_load: 40, load_unit: :lb, implement_count: 2)
  segment.exercises.build(movement: pull_up, position: 2, reps: 21)
end

# ==============================================================================
# Estrada
# 100 box step-ups with a weighted backpack; then 3 rounds: 800m run, 17-calorie bike, 25 front squats
Workout.find_or_create_by(name: 'Estrada') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: box_step_up, position: 1, reps: 100, notes: 'With a weighted backpack.', female_distance: 20, male_distance: 20,
                          distance_unit: :inch, female_load: 35, male_load: 50, load_unit: :lb)
  triplet = workout.segments.build(rounds: 3, position: 2)
  triplet.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  triplet.exercises.build(movement: bike, position: 2, reps: 1, calories: 17)
  triplet.exercises.build(movement: front_squat, position: 3, reps: 25, female_load: 135, male_load: 185, load_unit: :lb)
end

# ==============================================================================
# Eva Strong
# 5 rounds for time with a partner: 24 double-unders (each), 19 toes-to-bar (total),
# 2 clean and jerks (135/205 lb, total), 400-meter run (together)
Workout.find_or_create_by(name: 'Eva Strong') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  workout.team_size = 2
  workout.notes = 'With a partner. Reps are marked “each” or “total” per movement.'
  segment.exercises.build(movement: double_under, position: 1, reps: 24, notes: 'Each partner.')
  segment.exercises.build(movement: toes_to_bar, position: 2, reps: 19, notes: 'Total, split between partners.')
  segment.exercises.build(movement: clean_and_jerk, position: 3, reps: 2, female_load: 135, male_load: 205, load_unit: :lb,
                          notes: 'Total, split between partners.')
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 400, distance_unit: :meter, notes: 'Run together.')
end

# ==============================================================================
# Falkel
# AMRAP in 25 minutes: 8 handstand push-ups, 8 box jumps, 1 rope climb to 15 feet
Workout.find_or_create_by(name: 'Falkel') do |workout|
  segment = workout.segments.build(time_seconds: 1500, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: handstand_push_up, position: 1, reps: 8)
  segment.exercises.build(movement: box_jump, position: 2, reps: 8, female_distance: 24, male_distance: 30, distance_unit: :inch)
  segment.exercises.build(movement: rope_climb, position: 3, reps: 1, distance: 15, distance_unit: :foot)
end

# ==============================================================================
# Feeks
# For time: ascending pairs (2,4,...,16) of 100m shuttle sprints and dumbbell squat clean thrusters
Workout.find_or_create_by(name: 'Feeks') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  position = 1
  [2, 4, 6, 8, 10, 12, 14, 16].each do |reps|
    segment.exercises.build(movement: shuttle_run, position:, reps:, notes: '100-meter shuttle sprints.')
    position += 1
    segment.exercises.build(movement: dumbbell_squat_clean_thruster, position:, reps:, female_load: 45, male_load: 65, load_unit: :lb, implement_count: 2)
    position += 1
  end
end

# ==============================================================================
# FERN
# 60-minute cap, for time: 2-mile run; 9 rounds (20-cal row, 20 burpees); 3 rounds (30 push-ups, 30 pull-ups, 30 burpees)
Workout.find_or_create_by(name: 'FERN') do |workout|
  workout.score_type = :time
  workout.notes = 'Wear a 14-lb (♀) / 20-lb (♂) weight vest.'
  workout.time_cap = '60:00'
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 3200, distance_unit: :meter)
  couplet = workout.segments.build(rounds: 9, position: 2)
  couplet.exercises.build(movement: row, position: 1, reps: 1, calories: 20)
  couplet.exercises.build(movement: burpee, position: 2, reps: 20)
  triplet = workout.segments.build(rounds: 3, position: 3)
  triplet.exercises.build(movement: push_up, position: 1, reps: 30)
  triplet.exercises.build(movement: pull_up, position: 2, reps: 30)
  triplet.exercises.build(movement: burpee, position: 3, reps: 30)
end

# ==============================================================================
# Finseth
# 18-minute clock for reps: 83 wall-ball shots, then AMRAP of 2 power cleans, 18 push-ups, 24 double-unders
Workout.find_or_create_by(name: 'Finseth') do |workout|
  segment = workout.segments.build(time_seconds: 1080, position: 1)
  workout.score_type = :rep
  workout.notes = 'Complete 83 wall-ball shots first, then AMRAP the triplet in the remaining time.'
  segment.exercises.build(movement: wall_ball_shot, position: 1, reps: 83, female_load: 14, male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: power_clean, position: 2, reps: 2, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: push_up, position: 3, reps: 18)
  segment.exercises.build(movement: double_under, position: 4, reps: 24)
end

# ==============================================================================
# Foo
# For time: 13 bench presses; then AMRAP in 20 minutes: 7 chest-to-bar pull-ups, 77 double-unders,
# 2 squat clean thrusters, 28 sit-ups
Workout.find_or_create_by(name: 'Foo') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :rep
  workout.notes = 'Complete 13 bench presses first, then the 20-minute AMRAP.'
  segment.exercises.build(movement: bench_press, position: 1, reps: 13, female_load: 110, male_load: 170, load_unit: :lb)
  segment.exercises.build(movement: chest_to_bar_pull_up, position: 2, reps: 7)
  segment.exercises.build(movement: double_under, position: 3, reps: 77)
  segment.exercises.build(movement: squat_clean_thruster, position: 4, reps: 2, female_load: 110, male_load: 170, load_unit: :lb)
  segment.exercises.build(movement: sit_up, position: 5, reps: 28)
end

# ==============================================================================
# Forrest
# 3 rounds for time: 20 L pull-ups, 30 toes-to-bars, 40 burpees, run 800m
Workout.find_or_create_by(name: 'Forrest') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: l_pull_up, position: 1, reps: 20)
  segment.exercises.build(movement: toes_to_bar, position: 2, reps: 30)
  segment.exercises.build(movement: burpee, position: 3, reps: 40)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 800, distance_unit: :meter)
end

# ==============================================================================
# Fournier
# For time: 50 shoulder-to-overheads, 50-ft sled pull, 40 burpees, 50-ft sled pull, 30 SDHP, 50-ft sled pull
Workout.find_or_create_by(name: 'Fournier') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  workout.notes = 'For the sled pull, use a load that is challenging but does not require extended rest periods.'
  segment.exercises.build(movement: shoulder_to_overhead, position: 1, reps: 50, female_load: 75, male_load: 115, load_unit: :lb)
  segment.exercises.build(movement: sled_pull, position: 2, reps: 1, distance: 50, distance_unit: :foot, notes: 'Arm-over-arm.')
  segment.exercises.build(movement: burpee, position: 3, reps: 40)
  segment.exercises.build(movement: sled_pull, position: 4, reps: 1, distance: 50, distance_unit: :foot, notes: 'Arm-over-arm.')
  segment.exercises.build(movement: sumo_deadlift_high_pull, position: 5, reps: 30, female_load: 55, male_load: 85, load_unit: :lb)
  segment.exercises.build(movement: sled_pull, position: 6, reps: 1, distance: 50, distance_unit: :foot, notes: 'Arm-over-arm.')
end

# ==============================================================================
# Gage
# For time: 1,996m row; 3 rounds (12 power cleans, 11 back squats, 3 rope climbs to 15 feet, 27 burpees); 2,024m row
Workout.find_or_create_by(name: 'Gage') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 1996, distance_unit: :meter)
  triplet = workout.segments.build(rounds: 3, position: 2)
  triplet.exercises.build(movement: power_clean, position: 1, reps: 12, female_load: 105, male_load: 155, load_unit: :lb)
  triplet.exercises.build(movement: back_squat, position: 2, reps: 11, female_load: 105, male_load: 155, load_unit: :lb)
  triplet.exercises.build(movement: rope_climb, position: 3, reps: 3, distance: 15, distance_unit: :foot)
  triplet.exercises.build(movement: burpee, position: 4, reps: 27)
  segment = workout.segments.build(position: 3)
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 2024, distance_unit: :meter)
end

# ==============================================================================
# Gale Force
# AMRAP in 30 minutes: 20 box step-ups w/ weighted backpack, 23 burpees-over-backpack, 19 air squats
Workout.find_or_create_by(name: 'Gale Force') do |workout|
  segment = workout.segments.build(time_seconds: 1800, position: 1)
  workout.score_type = :rep
  workout.notes = 'When 30 minutes elapse, complete one more set of 19 squats together as a group.'
  segment.exercises.build(movement: box_step_up, position: 1, reps: 20, notes: 'With a weighted backpack.', female_distance: 20, male_distance: 24,
                          distance_unit: :inch, female_load: 35, male_load: 50, load_unit: :lb)
  segment.exercises.build(movement: burpee, position: 2, reps: 23, notes: 'Over the backpack.')
  segment.exercises.build(movement: air_squat, position: 3, reps: 19)
end

# ==============================================================================
# Gallant
# For time: 1-mile run w/ med ball, 60 burpee pull-ups, 800m run w/ med ball, 30 burpee pull-ups,
# 400m run w/ med ball, 15 burpee pull-ups
Workout.find_or_create_by(name: 'Gallant') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 1600, distance_unit: :meter, notes: 'Carry a medicine ball.', female_load: 14,
                          male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: burpee_pull_up, position: 2, reps: 60)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 800, distance_unit: :meter, notes: 'Carry a medicine ball.', female_load: 14,
                          male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: burpee_pull_up, position: 4, reps: 30)
  segment.exercises.build(movement: run, position: 5, reps: 1, distance: 400, distance_unit: :meter, notes: 'Carry a medicine ball.', female_load: 14,
                          male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: burpee_pull_up, position: 6, reps: 15)
end

# ==============================================================================
# Garbo
# On a 21-minute clock: 400m run, then AMRAP: 10 hand-release push-ups, 4 strict pull-ups, 20 KB swings, 10 KB goblet squats
Workout.find_or_create_by(name: 'Garbo') do |workout|
  segment = workout.segments.build(time_seconds: 1260, position: 1)
  workout.score_type = :rep
  workout.notes = 'Run 400 meters, then AMRAP the quad in the remaining time.'
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: hand_release_push_up, position: 2, reps: 10)
  segment.exercises.build(movement: strict_pull_up, position: 3, reps: 4)
  segment.exercises.build(movement: kettlebell_swing, position: 4, reps: 20, female_load: 35, male_load: 53, load_unit: :lb)
  segment.exercises.build(movement: kettlebell_goblet_squat, position: 5, reps: 10, female_load: 35, male_load: 53, load_unit: :lb)
end

# ==============================================================================
# Garrett
# 3 rounds for time: 75 squats, 25 ring handstand push-ups, 25 L pull-ups
Workout.find_or_create_by(name: 'Garrett') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: air_squat, position: 1, reps: 75)
  segment.exercises.build(movement: ring_handstand_push_up, position: 2, reps: 25)
  segment.exercises.build(movement: l_pull_up, position: 3, reps: 25)
end

# ==============================================================================
# Gator
# 8 rounds for time: 5 front squats, 26 ring push-ups
Workout.find_or_create_by(name: 'Gator') do |workout|
  segment = workout.segments.build(rounds: 8, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: front_squat, position: 1, reps: 5, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: ring_push_up, position: 2, reps: 26)
end

# ==============================================================================
# Gaza
# 5 rounds for time: 35 kettlebell swings, 30 push-ups, 25 pull-ups, 20 box jumps, 1-mile run
Workout.find_or_create_by(name: 'Gaza') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: kettlebell_swing, position: 1, reps: 35, female_load: 35, male_load: 53, load_unit: :lb)
  segment.exercises.build(movement: push_up, position: 2, reps: 30)
  segment.exercises.build(movement: pull_up, position: 3, reps: 25)
  segment.exercises.build(movement: box_jump, position: 4, reps: 20, female_distance: 24, male_distance: 30, distance_unit: :inch)
  segment.exercises.build(movement: run, position: 5, reps: 1, distance: 1600, distance_unit: :meter)
end

# ==============================================================================
# Glen
# For time: 30 clean and jerks, run 1 mile, 10 rope climbs to 15 feet, run 1 mile, 100 burpees
Workout.find_or_create_by(name: 'Glen') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: clean_and_jerk, position: 1, reps: 30, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: run, position: 2, reps: 1, distance: 1600, distance_unit: :meter)
  segment.exercises.build(movement: rope_climb, position: 3, reps: 10, distance: 15, distance_unit: :foot)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 1600, distance_unit: :meter)
  segment.exercises.build(movement: burpee, position: 5, reps: 100)
end

# ==============================================================================
# Goose
# For time with a partner: 106 deadlifts (95/135 lb); then 7 rounds of 3 rope climbs,
# 15 thrusters (95/135 lb), 15 kettlebell swings (53/70 lb); then a 400-meter run
# carrying a plate (25/45 lb)
Workout.find_or_create_by(name: 'Goose') do |workout|
  workout.score_type = :time
  workout.team_size = 2
  workout.notes = 'With a partner.'
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: deadlift, position: 1, reps: 106, female_load: 95, male_load: 135, load_unit: :lb)
  triplet = workout.segments.build(rounds: 7, position: 2)
  triplet.exercises.build(movement: rope_climb, position: 1, reps: 3)
  triplet.exercises.build(movement: thruster, position: 2, reps: 15, female_load: 95, male_load: 135, load_unit: :lb)
  triplet.exercises.build(movement: kettlebell_swing, position: 3, reps: 15, female_load: 53, male_load: 70, load_unit: :lb)
  segment = workout.segments.build(position: 3)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter, female_load: 25, male_load: 45, load_unit: :lb,
                          notes: 'Carry a plate; both partners carry.')
end

# ==============================================================================
# Griff
# For time: run 800m, run 400m backwards, run 800m, run 400m backwards
Workout.find_or_create_by(name: 'Griff') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: run, position: 2, reps: 1, distance: 400, distance_unit: :meter, notes: 'Run backwards.')
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 400, distance_unit: :meter, notes: 'Run backwards.')
end

# ==============================================================================
# Hall
# 5 rounds for time: 3 cleans, 200m sprint, 20 kettlebell snatches (10 each arm). Rest 2 minutes between rounds.
Workout.find_or_create_by(name: 'Hall') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  workout.notes = 'Rest 2 minutes between rounds.'
  segment.exercises.build(movement: clean, position: 1, reps: 3, female_load: 155, male_load: 225, load_unit: :lb)
  segment.exercises.build(movement: run, position: 2, reps: 1, distance: 200, distance_unit: :meter, notes: 'Sprint.')
  segment.exercises.build(movement: kettlebell_snatch, position: 3, reps: 20, notes: '10 each arm.', female_load: 35, male_load: 53, load_unit: :lb)
end

# ==============================================================================
# Hamilton
# 3 rounds for time: row 1,000m, 50 push-ups, run 1,000m, 50 pull-ups
Workout.find_or_create_by(name: 'Hamilton') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 1000, distance_unit: :meter)
  segment.exercises.build(movement: push_up, position: 2, reps: 50)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 1000, distance_unit: :meter)
  segment.exercises.build(movement: pull_up, position: 4, reps: 50)
end

# ==============================================================================
# Hammer
# 5 rounds, each for time: 5 power cleans, 10 front squats, 5 jerks, 20 pull-ups. Rest 90 seconds between rounds.
Workout.find_or_create_by(name: 'Hammer') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  workout.notes = 'Each round is for time. Rest 90 seconds between rounds.'
  segment.exercises.build(movement: power_clean, position: 1, reps: 5, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: front_squat, position: 2, reps: 10, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: jerk, position: 3, reps: 5, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 4, reps: 20)
end

# ==============================================================================
# Hammy
# For time: 1,200m run, 80 box step-overs, 40 hand-release push-ups, 800m run, 40 burpees to target,
# 20 strict pull-ups, 400m run, 20 burpee box jumps, 10 ring muscle-ups, 400m run, 40 burpees to target,
# 20 strict pull-ups, 800m run, 80 box step-overs, 40 hand-release push-ups, 1,200m run
Workout.find_or_create_by(name: 'Hammy') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 1200, distance_unit: :meter)
  segment.exercises.build(movement: box_step_over, position: 2, reps: 80, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: hand_release_push_up, position: 3, reps: 40)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: burpee_to_target, position: 5, reps: 40, distance: 6, distance_unit: :inch)
  segment.exercises.build(movement: strict_pull_up, position: 6, reps: 20)
  segment.exercises.build(movement: run, position: 7, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: burpee_box_jump, position: 8, reps: 20, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: ring_muscle_up, position: 9, reps: 10)
  segment.exercises.build(movement: run, position: 10, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: burpee_to_target, position: 11, reps: 40, distance: 6, distance_unit: :inch)
  segment.exercises.build(movement: strict_pull_up, position: 12, reps: 20)
  segment.exercises.build(movement: run, position: 13, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: box_step_over, position: 14, reps: 80, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: hand_release_push_up, position: 15, reps: 40)
  segment.exercises.build(movement: run, position: 16, reps: 1, distance: 1200, distance_unit: :meter)
end

# ==============================================================================
# Hansen
# 5 rounds for time: 30 kettlebell swings, 30 burpees, 30 GHD sit-ups
Workout.find_or_create_by(name: 'Hansen') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: kettlebell_swing, position: 1, reps: 30, female_load: 53, male_load: 70, load_unit: :lb)
  segment.exercises.build(movement: burpee, position: 2, reps: 30)
  segment.exercises.build(movement: ghd_sit_up, position: 3, reps: 30)
end

# ==============================================================================
# Harper
# AMRAP in 23 minutes: 9 chest-to-bar pull-ups, 15 power cleans, 21 squats, 400m run with a plate
Workout.find_or_create_by(name: 'Harper') do |workout|
  segment = workout.segments.build(time_seconds: 1380, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: chest_to_bar_pull_up, position: 1, reps: 9)
  segment.exercises.build(movement: power_clean, position: 2, reps: 15, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: air_squat, position: 3, reps: 21)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 400, distance_unit: :meter, notes: 'Carry a plate.', female_load: 25, male_load: 45,
                          load_unit: :lb)
end

# ==============================================================================
# Havana
# AMRAP in 25 minutes: 150 double-unders, 50 push-ups, 15 power cleans
Workout.find_or_create_by(name: 'Havana') do |workout|
  segment = workout.segments.build(time_seconds: 1500, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: double_under, position: 1, reps: 150)
  segment.exercises.build(movement: push_up, position: 2, reps: 50)
  segment.exercises.build(movement: power_clean, position: 3, reps: 15, female_load: 125, male_load: 185, load_unit: :lb)
end

# ==============================================================================
# Helton
# 3 rounds for time: 800m run, 30 dumbbell squat cleans, 30 burpees
Workout.find_or_create_by(name: 'Helton') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: dumbbell_squat_clean, position: 2, reps: 30, female_load: 35, male_load: 50, load_unit: :lb, implement_count: 2)
  segment.exercises.build(movement: burpee, position: 3, reps: 30)
end

# ==============================================================================
# Hidalgo
# For time: run 2 miles, rest 2 min, 20 squat cleans, 20 box jumps, 20 overhead walking lunges,
# 20 box jumps, 20 squat cleans, rest 2 min, run 2 miles
Workout.find_or_create_by(name: 'Hidalgo') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  workout.notes = 'If you’ve got a 20-lb vest or body armor, wear it. ' \
                  'The PDF prints the ' \
                  'male squat-clean barbell as 35 lb (a dropped-digit typo, below the 95-lb ' \
                  'female load); corrected here to 135 lb.'
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 3200, distance_unit: :meter)
  segment.exercises.build(movement: rest, position: 2, duration_seconds: 120)
  segment.exercises.build(movement: clean_squat, position: 3, reps: 20, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 4, reps: 20, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: overhead_walking_lunge, position: 5, reps: 20, female_load: 25, male_load: 45, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 6, reps: 20, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: clean_squat, position: 7, reps: 20, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: rest, position: 8, duration_seconds: 120)
  segment.exercises.build(movement: run, position: 9, reps: 1, distance: 3200, distance_unit: :meter)
end

# ==============================================================================
# Hildy
# For time: 100-calorie row, 75 thrusters, 50 pull-ups, 75 wall-ball shots, 100-calorie row
Workout.find_or_create_by(name: 'Hildy') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  workout.notes = 'Wear a 14-lb (♀) / 20-lb (♂) weight vest.'
  segment.exercises.build(movement: row, position: 1, reps: 1, calories: 100)
  segment.exercises.build(movement: thruster, position: 2, reps: 75, female_load: 35, male_load: 45, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 3, reps: 50)
  segment.exercises.build(movement: wall_ball_shot, position: 4, reps: 75, distance: 9, distance_unit: :foot, female_load: 14, male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: row, position: 5, reps: 1, calories: 100)
end

# ==============================================================================
# Holbrook
# 10 rounds, each for time: 5 thrusters, 10 pull-ups, 100m sprint. Rest 1 minute between rounds.
Workout.find_or_create_by(name: 'Holbrook') do |workout|
  segment = workout.segments.build(rounds: 10, position: 1)
  workout.score_type = :time
  workout.notes = 'Each round is for time. Rest 1 minute between rounds.'
  segment.exercises.build(movement: thruster, position: 1, reps: 5, female_load: 75, male_load: 115, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 2, reps: 10)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 100, distance_unit: :meter, notes: 'Sprint.')
end

# ==============================================================================
# Holleyman
# 30 rounds for time: 5 wall-ball shots, 3 handstand push-ups, 1 power clean
Workout.find_or_create_by(name: 'Holleyman') do |workout|
  segment = workout.segments.build(rounds: 30, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: wall_ball_shot, position: 1, reps: 5, female_load: 14, male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: handstand_push_up, position: 2, reps: 3)
  segment.exercises.build(movement: power_clean, position: 3, reps: 1, female_load: 155, male_load: 225, load_unit: :lb)
end

# ==============================================================================
# Hollywood
# For time: run 2,000m, 22 wall-ball shots, 22 muscle-ups, 22 wall-ball shots, 22 power cleans, 22 wall-ball shots, run 2,000m
Workout.find_or_create_by(name: 'Hollywood') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 2000, distance_unit: :meter)
  segment.exercises.build(movement: wall_ball_shot, position: 2, reps: 22, distance: 9, distance_unit: :foot, female_load: 20, male_load: 30, load_unit: :lb)
  segment.exercises.build(movement: muscle_up, position: 3, reps: 22)
  segment.exercises.build(movement: wall_ball_shot, position: 4, reps: 22, female_load: 20, male_load: 30, load_unit: :lb, distance: 9, distance_unit: :foot)
  segment.exercises.build(movement: power_clean, position: 5, reps: 22, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: wall_ball_shot, position: 6, reps: 22, female_load: 20, male_load: 30, load_unit: :lb)
  segment.exercises.build(movement: run, position: 7, reps: 1, distance: 2000, distance_unit: :meter)
end

# ==============================================================================
# Hoover
# 8 rounds for time: run 400m, 15 burpee box jump-overs, 10-calorie bike, 6 alternating dumbbell snatches
Workout.find_or_create_by(name: 'Hoover') do |workout|
  segment = workout.segments.build(rounds: 8, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: burpee_box_jump_over, position: 2, reps: 15, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: bike, position: 3, reps: 1, calories: 10)
  segment.exercises.build(movement: dumbbell_power_snatch, position: 4, reps: 6, notes: 'Alternating arms.', female_load: 50, male_load: 75, load_unit: :lb)
end

# ==============================================================================
# Hortman
# AMRAP in 45 minutes: run 800m, 80 squats, 8 muscle-ups
Workout.find_or_create_by(name: 'Hortman') do |workout|
  segment = workout.segments.build(time_seconds: 2700, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: air_squat, position: 2, reps: 80)
  segment.exercises.build(movement: muscle_up, position: 3, reps: 8)
end

# ==============================================================================
# Horton
# 9 rounds for time with a partner: 9 bar muscle-ups, 11 clean-and-jerks (115/155 lb),
# 50-yard buddy carry
Workout.find_or_create_by(name: 'Horton') do |workout|
  segment = workout.segments.build(rounds: 9, position: 1)
  workout.score_type = :time
  workout.team_size = 2
  workout.notes = 'With a partner.'
  segment.exercises.build(movement: bar_muscle_up, position: 1, reps: 9)
  segment.exercises.build(movement: clean_and_jerk, position: 2, reps: 11, female_load: 115, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: buddy_carry, position: 3, reps: 1, distance: 150, distance_unit: :foot, notes: '50-yard buddy carry.')
end

# ==============================================================================
# Hotshots 19
# 6 rounds for time: 30 squats, 19 power cleans, 7 strict pull-ups, 400m run
Workout.find_or_create_by(name: 'Hotshots 19') do |workout|
  segment = workout.segments.build(rounds: 6, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: air_squat, position: 1, reps: 30)
  segment.exercises.build(movement: power_clean, position: 2, reps: 19, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: strict_pull_up, position: 3, reps: 7)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 400, distance_unit: :meter)
end

# ==============================================================================
# J.J.
# For time: ascending squat cleans (1..10) paired with descending parallette handstand push-ups (10..1)
Workout.find_or_create_by(name: 'J.J.') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  position = 1
  (1..10).each do |round|
    segment.exercises.build(movement: clean_squat, position:, reps: round, female_load: 125, male_load: 185, load_unit: :lb)
    position += 1
    segment.exercises.build(movement: parallette_handstand_push_up, position:, reps: 11 - round)
    position += 1
  end
end

# ==============================================================================
# Jack
# AMRAP in 20 minutes: 10 push presses, 10 kettlebell swings, 10 box jumps
Workout.find_or_create_by(name: 'Jack') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: push_press, position: 1, reps: 10, female_load: 75, male_load: 115, load_unit: :lb)
  segment.exercises.build(movement: kettlebell_swing, position: 2, reps: 10, female_load: 35, male_load: 53, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 3, reps: 10, female_distance: 20, male_distance: 24, distance_unit: :inch)
end

# ==============================================================================
# Jack's Triangle
# 23-minute clock for total reps: 0:00-2:00 max deadlifts (155/225 lb); 2:00-21:00 AMRAP of
# 4 strict pull-ups, 11 box jumps, 13 hand-release push-ups, 23-cal bike; 21:00-23:00 max deadlifts
Workout.find_or_create_by(name: "Jack's Triangle") do |workout|
  workout.score_type = :rep
  opening = workout.segments.build(position: 1, name: '0:00-2:00 max deadlifts', time_seconds: 120)
  opening.exercises.build(movement: deadlift, position: 1, reps: 0, female_load: 155, male_load: 225, load_unit: :lb)
  amrap = workout.segments.build(position: 2, name: '2:00-21:00 AMRAP', time_seconds: 1140)
  amrap.exercises.build(movement: strict_pull_up, position: 1, reps: 4)
  amrap.exercises.build(movement: box_jump, position: 2, reps: 11)
  amrap.exercises.build(movement: hand_release_push_up, position: 3, reps: 13)
  amrap.exercises.build(movement: bike, position: 4, reps: 1, calories: 23)
  closing = workout.segments.build(position: 3, name: '21:00-23:00 max deadlifts', time_seconds: 120)
  closing.exercises.build(movement: deadlift, position: 1, reps: 0, female_load: 155, male_load: 225, load_unit: :lb)
end

# ==============================================================================
# Jag 28
# For time: run 800m, 28 KB swings, 28 strict pull-ups, 28 KB clean and jerks, 28 strict pull-ups, run 800m
Workout.find_or_create_by(name: 'Jag 28') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: kettlebell_swing, position: 2, reps: 28, female_load: 53, male_load: 70, load_unit: :lb)
  segment.exercises.build(movement: strict_pull_up, position: 3, reps: 28)
  segment.exercises.build(movement: kettlebell_clean_and_jerk, position: 4, reps: 28, female_load: 53, male_load: 70, load_unit: :lb)
  segment.exercises.build(movement: strict_pull_up, position: 5, reps: 28)
  segment.exercises.build(movement: run, position: 6, reps: 1, distance: 800, distance_unit: :meter)
end

# ==============================================================================
# Jared
# 4 rounds for time: run 800m, 40 pull-ups, 70 push-ups
Workout.find_or_create_by(name: 'Jared') do |workout|
  segment = workout.segments.build(rounds: 4, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: pull_up, position: 2, reps: 40)
  segment.exercises.build(movement: push_up, position: 3, reps: 70)
end

# ==============================================================================
# Jason
# For time: 100 squats, 5 muscle-ups, 75 squats, 10 muscle-ups, 50 squats, 15 muscle-ups, 25 squats, 20 muscle-ups
Workout.find_or_create_by(name: 'Jason') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: air_squat, position: 1, reps: 100)
  segment.exercises.build(movement: muscle_up, position: 2, reps: 5)
  segment.exercises.build(movement: air_squat, position: 3, reps: 75)
  segment.exercises.build(movement: muscle_up, position: 4, reps: 10)
  segment.exercises.build(movement: air_squat, position: 5, reps: 50)
  segment.exercises.build(movement: muscle_up, position: 6, reps: 15)
  segment.exercises.build(movement: air_squat, position: 7, reps: 25)
  segment.exercises.build(movement: muscle_up, position: 8, reps: 20)
end

# ==============================================================================
# JBo
# AMRAP in 28 minutes: 9 overhead squats, 12 bench presses
Workout.find_or_create_by(name: 'JBo') do |workout|
  segment = workout.segments.build(time_seconds: 1680, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: overhead_squat, position: 1, reps: 9, female_load: 75, male_load: 115, load_unit: :lb)
  segment.exercises.build(movement: bench_press, position: 2, reps: 12, female_load: 75, male_load: 115, load_unit: :lb)
end

# ==============================================================================
# Jennifer
# AMRAP in 26 minutes: 10 pull-ups, 15 kettlebell swings, 20 box jumps
Workout.find_or_create_by(name: 'Jennifer') do |workout|
  segment = workout.segments.build(time_seconds: 1560, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: pull_up, position: 1, reps: 10)
  segment.exercises.build(movement: kettlebell_swing, position: 2, reps: 15, female_load: 35, male_load: 53, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 3, reps: 20, female_distance: 20, male_distance: 24, distance_unit: :inch)
end

# ==============================================================================
# Jenny
# AMRAP in 20 minutes: 20 overhead squats, 20 back squats, 400m run
Workout.find_or_create_by(name: 'Jenny') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: overhead_squat, position: 1, reps: 20, female_load: 35, male_load: 45, load_unit: :lb)
  segment.exercises.build(movement: back_squat, position: 2, reps: 20, female_load: 35, male_load: 45, load_unit: :lb)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 400, distance_unit: :meter)
end

# ==============================================================================
# Jerry
# For time: run 1 mile, row 2K, run 1 mile
Workout.find_or_create_by(name: 'Jerry') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 1600, distance_unit: :meter)
  segment.exercises.build(movement: row, position: 2, reps: 1, distance: 2000, distance_unit: :meter)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 1600, distance_unit: :meter)
end

# ==============================================================================
# Johnson
# AMRAP in 20 minutes: 9 deadlifts, 8 muscle-ups, 9 squat cleans
Workout.find_or_create_by(name: 'Johnson') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: deadlift, position: 1, reps: 9, female_load: 165, male_load: 245, load_unit: :lb)
  segment.exercises.build(movement: muscle_up, position: 2, reps: 8)
  segment.exercises.build(movement: clean_squat, position: 3, reps: 9, female_load: 105, male_load: 155, load_unit: :lb)
end

# ==============================================================================
# Jonathon Farmer
# For time: 1,500m row; 2 rounds (53 push-ups, 11 pull-ups, 5 shoulder presses, 100m farmers carry,
# 50m sled push, 300m sprint); 1,500m row
Workout.find_or_create_by(name: 'Jonathon Farmer') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 1500, distance_unit: :meter)
  rounds = workout.segments.build(rounds: 2, position: 2)
  rounds.exercises.build(movement: push_up, position: 1, reps: 53)
  rounds.exercises.build(movement: pull_up, position: 2, reps: 11)
  rounds.exercises.build(movement: shoulder_press, position: 3, reps: 5, female_load: 95, male_load: 135, load_unit: :lb)
  rounds.exercises.build(movement: farmers_carry, position: 4, reps: 1, distance: 100, distance_unit: :meter, female_load: 35, male_load: 70, load_unit: :lb)
  rounds.exercises.build(movement: sled_push, position: 5, reps: 1, distance: 50, distance_unit: :meter, female_load: 45, male_load: 90, load_unit: :lb)
  rounds.exercises.build(movement: run, position: 6, reps: 1, distance: 300, distance_unit: :meter, notes: 'Sprint.')
  segment = workout.segments.build(position: 3)
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 1500, distance_unit: :meter)
end

# ==============================================================================
# Jorge
# For time: 30 GHD sit-ups, 15 squat cleans, 24 GHD sit-ups, 12 squat cleans, 18 GHD sit-ups, 9 squat cleans,
# 12 GHD sit-ups, 6 squat cleans, 6 GHD sit-ups, 3 squat cleans
Workout.find_or_create_by(name: 'Jorge') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: ghd_sit_up, position: 1, reps: 30)
  segment.exercises.build(movement: clean_squat, position: 2, reps: 15, female_load: 105, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: ghd_sit_up, position: 3, reps: 24)
  segment.exercises.build(movement: clean_squat, position: 4, reps: 12, female_load: 105, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: ghd_sit_up, position: 5, reps: 18)
  segment.exercises.build(movement: clean_squat, position: 6, reps: 9, female_load: 105, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: ghd_sit_up, position: 7, reps: 12)
  segment.exercises.build(movement: clean_squat, position: 8, reps: 6, female_load: 105, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: ghd_sit_up, position: 9, reps: 6)
  segment.exercises.build(movement: clean_squat, position: 10, reps: 3, female_load: 105, male_load: 155, load_unit: :lb)
end

# ==============================================================================
# Josh
# For time: 21 overhead squats, 42 pull-ups, 15 overhead squats, 30 pull-ups, 9 overhead squats, 18 pull-ups
Workout.find_or_create_by(name: 'Josh') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: overhead_squat, position: 1, reps: 21, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 2, reps: 42)
  segment.exercises.build(movement: overhead_squat, position: 3, reps: 15, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 4, reps: 30)
  segment.exercises.build(movement: overhead_squat, position: 5, reps: 9, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 6, reps: 18)
end

# ==============================================================================
# Josh-O
# For time with a partner: 400-meter run; 2 rounds of 44 dumbbell front squats,
# 44 dumbbell floor presses, 44 dumbbell hang clean and jerks; 1,979-meter row;
# 2 rounds of 44 dumbbell deadlifts, 44 dumbbell bent-over rows, 44 dumbbell lunges;
# 400-meter run. Run together and split all other work as needed. Use two dumbbells.
Workout.find_or_create_by(name: 'Josh-O') do |workout|
  workout.score_type = :time
  workout.team_size = 2
  workout.notes = 'With a partner. Run together and split all other work as needed. Use two dumbbells.'
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter, notes: 'Run together.')
  first_couplet = workout.segments.build(rounds: 2, position: 2)
  first_couplet.exercises.build(movement: dumbbell_front_squat, position: 1, reps: 44)
  first_couplet.exercises.build(movement: dumbbell_floor_press, position: 2, reps: 44)
  first_couplet.exercises.build(movement: dumbbell_hang_clean_and_jerk, position: 3, reps: 44)
  segment = workout.segments.build(position: 3)
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 1979, distance_unit: :meter)
  second_couplet = workout.segments.build(rounds: 2, position: 4)
  second_couplet.exercises.build(movement: dumbbell_deadlift, position: 1, reps: 44)
  second_couplet.exercises.build(movement: dumbbell_bent_over_row, position: 2, reps: 44)
  second_couplet.exercises.build(movement: dumbbell_lunge, position: 3, reps: 44)
  segment = workout.segments.build(position: 5)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter, notes: 'Run together.')
end

# ==============================================================================
# Joshie
# 3 rounds for time: 21 dumbbell snatches (R), 21 L pull-ups, 21 dumbbell snatches (L), 21 L pull-ups
Workout.find_or_create_by(name: 'Joshie') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: dumbbell_power_snatch, position: 1, reps: 21, notes: 'Right arm.', female_load: 25, male_load: 40, load_unit: :lb)
  segment.exercises.build(movement: l_pull_up, position: 2, reps: 21)
  segment.exercises.build(movement: dumbbell_power_snatch, position: 3, reps: 21, notes: 'Left arm.', female_load: 25, male_load: 40, load_unit: :lb)
  segment.exercises.build(movement: l_pull_up, position: 4, reps: 21)
end

# ==============================================================================
# Josie
# For time: 1-mile run; 3 rounds (30 burpees, 4 power cleans, 6 front squats); 1-mile run
Workout.find_or_create_by(name: 'Josie') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 1600, distance_unit: :meter)
  triplet = workout.segments.build(rounds: 3, position: 2)
  triplet.exercises.build(movement: burpee, position: 1, reps: 30)
  triplet.exercises.build(movement: power_clean, position: 2, reps: 4, female_load: 105, male_load: 155, load_unit: :lb)
  triplet.exercises.build(movement: front_squat, position: 3, reps: 6, female_load: 105, male_load: 155, load_unit: :lb)
  segment = workout.segments.build(position: 3)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 1600, distance_unit: :meter)
end

# ==============================================================================
# JT
# 21-15-9 reps for time: handstand push-ups, ring dips, push-ups
Workout.find_or_create_by(name: 'JT') do |workout|
  segment = workout.segments.build(interval_scheme: '21-15-9', position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: handstand_push_up, position: 1, reps: 1)
  segment.exercises.build(movement: ring_dip, position: 2, reps: 1)
  segment.exercises.build(movement: push_up, position: 3, reps: 1)
end

# ==============================================================================
# Justin
# 30-20-10 reps for time: back squats, bench presses, strict pull-ups
Workout.find_or_create_by(name: 'Justin') do |workout|
  segment = workout.segments.build(interval_scheme: '30-20-10', position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: back_squat, position: 1, reps: 1)
  segment.exercises.build(movement: bench_press, position: 2, reps: 1)
  segment.exercises.build(movement: strict_pull_up, position: 3, reps: 1)
end

# ==============================================================================
# K27
# 27 rounds for time: 5 hang power cleans, 5 burpees, 15 double-unders
Workout.find_or_create_by(name: 'K27') do |workout|
  segment = workout.segments.build(rounds: 27, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: hang_power_clean, position: 1, reps: 5, female_load: 105, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: burpee, position: 2, reps: 5)
  segment.exercises.build(movement: double_under, position: 3, reps: 15)
end

# ==============================================================================
# Kelly Brown
# 5 rounds for time: row 440m, 10 box jumps, 10 deadlifts, 10 wall-ball shots
Workout.find_or_create_by(name: 'Kelly Brown') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 440, distance_unit: :meter)
  segment.exercises.build(movement: box_jump, position: 2, reps: 10, female_distance: 24, male_distance: 30, distance_unit: :inch)
  segment.exercises.build(movement: deadlift, position: 3, reps: 10, female_load: 185, male_load: 275, load_unit: :lb)
  segment.exercises.build(movement: wall_ball_shot, position: 4, reps: 10, female_load: 20, male_load: 30, load_unit: :lb)
end

# ==============================================================================
# Kerrie
# 10 rounds for time: 100m sprint, 5 burpees, 20 sit-ups, 15 push-ups, 100m sprint. Rest 2 minutes.
Workout.find_or_create_by(name: 'Kerrie') do |workout|
  segment = workout.segments.build(rounds: 10, position: 1)
  workout.score_type = :time
  workout.notes = 'Rest 2 minutes between rounds.'
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 100, distance_unit: :meter, notes: 'Sprint.')
  segment.exercises.build(movement: burpee, position: 2, reps: 5)
  segment.exercises.build(movement: sit_up, position: 3, reps: 20)
  segment.exercises.build(movement: push_up, position: 4, reps: 15)
  segment.exercises.build(movement: run, position: 5, reps: 1, distance: 100, distance_unit: :meter, notes: 'Sprint.')
end

# ==============================================================================
# Kev
# AMRAP in 26 minutes with a partner: 6 deadlifts (205/315 lb, each), 9 bar-facing
# burpees (synchronized), 9 bar muscle-ups (each), 55-foot partner barbell carry
# (205/315 lb)
Workout.find_or_create_by(name: 'Kev') do |workout|
  segment = workout.segments.build(time_seconds: 1560, position: 1)
  workout.score_type = :rep
  workout.team_size = 2
  workout.notes = 'With a partner.'
  segment.exercises.build(movement: deadlift, position: 1, reps: 6, female_load: 205, male_load: 315, load_unit: :lb, notes: 'Each partner.')
  segment.exercises.build(movement: bar_facing_burpee, position: 2, reps: 9, notes: 'Synchronized.')
  segment.exercises.build(movement: bar_muscle_up, position: 3, reps: 9, notes: 'Each partner.')
  segment.exercises.build(movement: barbell_carry, position: 4, reps: 1, distance: 55, distance_unit: :foot, female_load: 205, male_load: 315, load_unit: :lb,
                          notes: 'Partner barbell carry.')
end

# ==============================================================================
# Kevin
# 3 rounds for time: 32 deadlifts, 32 hanging hip touches (alternating), 800m running farmers carry
Workout.find_or_create_by(name: 'Kevin') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: deadlift, position: 1, reps: 32, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: hanging_hip_touch, position: 2, reps: 32, notes: 'Alternating arms.')
  segment.exercises.build(movement: farmers_carry, position: 3, reps: 1, distance: 800, distance_unit: :meter, notes: 'Running farmers carry.',
                          female_load: 10, male_load: 15, load_unit: :lb)
end

# ==============================================================================
# Klepto
# 4 rounds for time: 27 box jumps, 20 burpees, 11 squat cleans
Workout.find_or_create_by(name: 'Klepto') do |workout|
  segment = workout.segments.build(rounds: 4, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: box_jump, position: 1, reps: 27, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: burpee, position: 2, reps: 20)
  segment.exercises.build(movement: clean_squat, position: 3, reps: 11, female_load: 95, male_load: 145, load_unit: :lb)
end

# ==============================================================================
# Kutschbach
# 7 rounds for time: 11 back squats, 10 jerks
Workout.find_or_create_by(name: 'Kutschbach') do |workout|
  segment = workout.segments.build(rounds: 7, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: back_squat, position: 1, reps: 11, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: jerk, position: 2, reps: 10, female_load: 95, male_load: 135, load_unit: :lb)
end

# ==============================================================================
# Larry
# 21-18-15-12-9-6-3 reps for time: front squats, bar-facing burpees
Workout.find_or_create_by(name: 'Larry') do |workout|
  segment = workout.segments.build(interval_scheme: '21-18-15-12-9-6-3', position: 1)
  workout.score_type = :time
  workout.notes = 'Use a 50-lb (♀) / 80-lb (♂) sandbag.'
  segment.exercises.build(movement: front_squat, position: 1, reps: 1, female_load: 75, male_load: 115, load_unit: :lb)
  segment.exercises.build(movement: bar_facing_burpee, position: 2, reps: 1)
end

# ==============================================================================
# Laura
# AMRAP in 21 minutes with a partner: 30-calorie row, 20 burpees over the rower,
# 10 power cleans (105/155 lb). One partner works while the other rests.
Workout.find_or_create_by(name: 'Laura') do |workout|
  segment = workout.segments.build(time_seconds: 1260, position: 1)
  workout.score_type = :rep
  workout.team_size = 2
  workout.notes = 'With a partner; one works while the other rests.'
  segment.exercises.build(movement: row, position: 1, reps: 1, calories: 30)
  segment.exercises.build(movement: burpee_over_rower, position: 2, reps: 20)
  segment.exercises.build(movement: power_clean, position: 3, reps: 10, female_load: 105, male_load: 155, load_unit: :lb)
end

# ==============================================================================
# Ledesma
# AMRAP in 20 minutes: 5 parallette handstand push-ups, 10 toes-to-rings, 15 medicine-ball cleans
Workout.find_or_create_by(name: 'Ledesma') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: parallette_handstand_push_up, position: 1, reps: 5)
  segment.exercises.build(movement: toes_to_rings, position: 2, reps: 10)
  segment.exercises.build(movement: medicine_ball_clean, position: 3, reps: 15, female_load: 14, male_load: 20, load_unit: :lb)
end

# ==============================================================================
# Lee
# 5 rounds for time: 400m run, 1 deadlift, 3 squat cleans, 5 push jerks, 3 muscle-ups, 1 rope climb to 15 feet
Workout.find_or_create_by(name: 'Lee') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: deadlift, position: 2, reps: 1, female_load: 225, male_load: 345, load_unit: :lb)
  segment.exercises.build(movement: clean_squat, position: 3, reps: 3, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: push_jerk, position: 4, reps: 5, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: muscle_up, position: 5, reps: 3)
  segment.exercises.build(movement: rope_climb, position: 6, reps: 1, distance: 15, distance_unit: :foot)
end

# ==============================================================================
# Leehan
# 7 rounds (6 deadlifts, 6 air squats, 6 box jumps), then a 1,742m row
Workout.find_or_create_by(name: 'Leehan') do |workout|
  workout.score_type = :time
  rounds = workout.segments.build(rounds: 7, position: 1)
  rounds.exercises.build(movement: deadlift, position: 1, reps: 6, female_load: 125, male_load: 185, load_unit: :lb)
  rounds.exercises.build(movement: air_squat, position: 2, reps: 6)
  rounds.exercises.build(movement: box_jump, position: 3, reps: 6, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment = workout.segments.build(position: 2)
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 1742, distance_unit: :meter)
end

# ==============================================================================
# Liam
# For time: run 800m w/ plate, 100 toes-to-bars, 50 front squats, 10 rope climbs to 15 feet, run 800m w/ plate. Partition.
Workout.find_or_create_by(name: 'Liam') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  workout.notes = 'Partition the toes-to-bars, front squats, and rope climbs as needed.'
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter, notes: 'Carry a plate.', female_load: 25, male_load: 45,
                          load_unit: :lb)
  segment.exercises.build(movement: toes_to_bar, position: 2, reps: 100)
  segment.exercises.build(movement: front_squat, position: 3, reps: 50, female_load: 105, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: rope_climb, position: 4, reps: 10, distance: 15, distance_unit: :foot)
  segment.exercises.build(movement: run, position: 5, reps: 1, distance: 800, distance_unit: :meter, notes: 'Carry a plate.', female_load: 25, male_load: 45,
                          load_unit: :lb)
end

# ==============================================================================
# Locke
# For time: 565m row or run; 7 rounds (9 deadlifts, 25 push-ups, 21 box step-ups); 565m row or run
Workout.find_or_create_by(name: 'Locke') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 565, distance_unit: :meter, notes: 'Row or run.')
  rounds = workout.segments.build(rounds: 7, position: 2)
  rounds.exercises.build(movement: deadlift, position: 1, reps: 9, female_load: 125, male_load: 185, load_unit: :lb)
  rounds.exercises.build(movement: push_up, position: 2, reps: 25)
  rounds.exercises.build(movement: box_step_up, position: 3, reps: 21, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment = workout.segments.build(position: 3)
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 565, distance_unit: :meter, notes: 'Row or run.')
end

# ==============================================================================
# Loredo
# 6 rounds for time: 24 squats, 24 push-ups, 24 walking lunge steps, run 400m
Workout.find_or_create_by(name: 'Loredo') do |workout|
  segment = workout.segments.build(rounds: 6, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: air_squat, position: 1, reps: 24)
  segment.exercises.build(movement: push_up, position: 2, reps: 24)
  segment.exercises.build(movement: walking_lunge, position: 3, reps: 24)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 400, distance_unit: :meter)
end

# ==============================================================================
# Lorenzo
# For time: run 1,000m; 5 rounds (15 push-ups, 20 medicine-ball cleans, 21 burpees); run 1,000m
Workout.find_or_create_by(name: 'Lorenzo') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 1000, distance_unit: :meter)
  rounds = workout.segments.build(rounds: 5, position: 2)
  rounds.exercises.build(movement: push_up, position: 1, reps: 15)
  rounds.exercises.build(movement: medicine_ball_clean, position: 2, reps: 20)
  rounds.exercises.build(movement: burpee, position: 3, reps: 21)
  segment = workout.segments.build(position: 3)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 1000, distance_unit: :meter)
end

# ==============================================================================
# Luce
# Wearing a weight vest, 3 rounds for time: 1K run, 10 muscle-ups, 100 squats
Workout.find_or_create_by(name: 'Luce') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  workout.notes = 'Wear a 14-lb (♀) / 20-lb (♂) weight vest.'
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 1000, distance_unit: :meter)
  segment.exercises.build(movement: muscle_up, position: 2, reps: 10)
  segment.exercises.build(movement: air_squat, position: 3, reps: 100)
end

# ==============================================================================
# Luke
# For time: run 400m, 15 clean and jerks, run 400m, 30 toes-to-bars, run 400m, 45 wall-ball shots,
# run 400m, 45 kettlebell swings, run 400m, 30 ring dips, run 400m, 15 front-rack weighted lunges, run 400m
Workout.find_or_create_by(name: 'Luke') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: clean_and_jerk, position: 2, reps: 15, female_load: 105, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: toes_to_bar, position: 4, reps: 30)
  segment.exercises.build(movement: run, position: 5, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: wall_ball_shot, position: 6, reps: 45, distance: 9, distance_unit: :foot, female_load: 14, male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: run, position: 7, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: kettlebell_swing, position: 8, reps: 45, female_load: 35, male_load: 53, load_unit: :lb)
  segment.exercises.build(movement: run, position: 9, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: ring_dip, position: 10, reps: 30)
  segment.exercises.build(movement: run, position: 11, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: barbell_front_rack_lunge, position: 12, reps: 15, notes: 'Front-rack weighted lunge.', female_load: 105, male_load: 155,
                          load_unit: :lb)
  segment.exercises.build(movement: run, position: 13, reps: 1, distance: 400, distance_unit: :meter)
end

# ==============================================================================
# Lumberjack 20
# For time: 20 deadlifts, run 400m, 20 KB swings, run 400m, 20 overhead squats, run 400m, 20 burpees,
# run 400m, 20 chest-to-bar pull-ups, run 400m, 20 box jumps, run 400m, 20 dumbbell squat cleans, run 400m
Workout.find_or_create_by(name: 'Lumberjack 20') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: deadlift, position: 1, reps: 20, female_load: 185, male_load: 275, load_unit: :lb)
  segment.exercises.build(movement: run, position: 2, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: kettlebell_swing, position: 3, reps: 20, female_load: 53, male_load: 70, load_unit: :lb)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: overhead_squat, position: 5, reps: 20, female_load: 75, male_load: 115, load_unit: :lb)
  segment.exercises.build(movement: run, position: 6, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: burpee, position: 7, reps: 20)
  segment.exercises.build(movement: run, position: 8, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: chest_to_bar_pull_up, position: 9, reps: 20)
  segment.exercises.build(movement: run, position: 10, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: box_jump, position: 11, reps: 20, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: run, position: 12, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: dumbbell_squat_clean, position: 13, reps: 20, female_load: 30, male_load: 45, load_unit: :lb, implement_count: 2)
  segment.exercises.build(movement: run, position: 14, reps: 1, distance: 400, distance_unit: :meter)
end

# ==============================================================================
# Maloney
# 6 rounds for time: 300m shuttle run, 16 deadlifts, 6 hang power cleans. Rest 2 minutes between sets.
Workout.find_or_create_by(name: 'Maloney') do |workout|
  segment = workout.segments.build(rounds: 6, position: 1)
  workout.score_type = :time
  workout.notes = 'Rest 2 minutes between sets. The shuttle run is 50m out and back x6 or 100m out and back x3.'
  segment.exercises.build(movement: shuttle_run, position: 1, reps: 1, distance: 300, distance_unit: :meter)
  segment.exercises.build(movement: deadlift, position: 2, reps: 16, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: hang_power_clean, position: 3, reps: 6, female_load: 125, male_load: 185, load_unit: :lb)
end

# ==============================================================================
# Manion
# 7 rounds for time: 400m run, 29 back squats
Workout.find_or_create_by(name: 'Manion') do |workout|
  segment = workout.segments.build(rounds: 7, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: back_squat, position: 2, reps: 29, female_load: 95, male_load: 135, load_unit: :lb)
end

# ==============================================================================
# Manuel
# 5 rounds: 3 min rope climbs, 2 min squats, 2 min push-ups, 3 min to run 400m (rest remainder)
Workout.find_or_create_by(name: 'Manuel') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :rep
  workout.notes = 'After the 400m run, rest for the remainder of the 3 minutes before the next round.'
  segment.exercises.build(movement: rope_climb, position: 1, reps: 0, duration_seconds: 180)
  segment.exercises.build(movement: air_squat, position: 2, reps: 0, duration_seconds: 120)
  segment.exercises.build(movement: push_up, position: 3, reps: 0, duration_seconds: 120)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 400, distance_unit: :meter, duration_seconds: 180)
end

# ==============================================================================
# Marco
# 3 rounds for time: 21 pull-ups, 15 handstand push-ups, 9 thrusters
Workout.find_or_create_by(name: 'Marco') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: pull_up, position: 1, reps: 21)
  segment.exercises.build(movement: handstand_push_up, position: 2, reps: 15)
  segment.exercises.build(movement: thruster, position: 3, reps: 9, female_load: 95, male_load: 135, load_unit: :lb)
end

# ==============================================================================
# Marston
# AMRAP in 20 minutes: 1 deadlift, 10 toes-to-bars, 15 bar-facing burpees
Workout.find_or_create_by(name: 'Marston') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: deadlift, position: 1, reps: 1, female_load: 275, male_load: 405, load_unit: :lb)
  segment.exercises.build(movement: toes_to_bar, position: 2, reps: 10)
  segment.exercises.build(movement: bar_facing_burpee, position: 3, reps: 15)
end

# ==============================================================================
# Martin
# For time with a partner: 2,000-meter row, 100 deadlifts (bodyweight), 50 thrusters
# (30/43 kg), 1,000-meter row, 100 hand-release push-ups, 50 pull-ups, 500-meter row,
# 100 AbMat sit-ups, 100 wall-ball shots (14/20 lb)
Workout.find_or_create_by(name: 'Martin') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  workout.team_size = 2
  workout.notes = 'With a partner. Deadlifts at bodyweight.'
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 2000, distance_unit: :meter)
  segment.exercises.build(movement: deadlift, position: 2, reps: 100, notes: 'Bodyweight.')
  segment.exercises.build(movement: thruster, position: 3, reps: 50, female_load: 30, male_load: 43, load_unit: :kg)
  segment.exercises.build(movement: row, position: 4, reps: 1, distance: 1000, distance_unit: :meter)
  segment.exercises.build(movement: hand_release_push_up, position: 5, reps: 100)
  segment.exercises.build(movement: pull_up, position: 6, reps: 50)
  segment.exercises.build(movement: row, position: 7, reps: 1, distance: 500, distance_unit: :meter)
  segment.exercises.build(movement: abmat_sit_up, position: 8, reps: 100)
  segment.exercises.build(movement: wall_ball_shot, position: 9, reps: 100, female_load: 14, male_load: 20, load_unit: :lb)
end

# ==============================================================================
# Matt 16
# For time: 16 deadlifts, 16 hang power cleans, 16 push presses, run 800m (x3 sets, runs between)
Workout.find_or_create_by(name: 'Matt 16') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: deadlift, position: 1, reps: 16, female_load: 185, male_load: 275, load_unit: :lb)
  segment.exercises.build(movement: hang_power_clean, position: 2, reps: 16, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: push_press, position: 3, reps: 16, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: deadlift, position: 5, reps: 16, female_load: 185, male_load: 275, load_unit: :lb)
  segment.exercises.build(movement: hang_power_clean, position: 6, reps: 16, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: push_press, position: 7, reps: 16, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: run, position: 8, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: deadlift, position: 9, reps: 16, female_load: 185, male_load: 275, load_unit: :lb)
  segment.exercises.build(movement: hang_power_clean, position: 10, reps: 16, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: push_press, position: 11, reps: 16, female_load: 95, male_load: 135, load_unit: :lb)
end

# ==============================================================================
# Maupin
# 4 rounds for time: 800m run, 49 push-ups, 49 sit-ups, 49 squats
Workout.find_or_create_by(name: 'Maupin') do |workout|
  segment = workout.segments.build(rounds: 4, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: push_up, position: 2, reps: 49)
  segment.exercises.build(movement: sit_up, position: 3, reps: 49)
  segment.exercises.build(movement: air_squat, position: 4, reps: 49)
end

# ==============================================================================
# Maxim 56
# For time with a partner. Buy-in: each partner holds a 56-second handstand hold or
# wall sit. Then each athlete: 56 burpees, 56 flutter kicks, 56 walking lunges,
# 56 hand-release push-ups, 56 air squats. Cash-out: 5,600-meter run.
Workout.find_or_create_by(name: 'Maxim 56') do |workout|
  workout.score_type = :time
  workout.team_size = 2
  workout.notes = 'With a partner.'
  buy_in = workout.segments.build(position: 1, name: 'Buy-in')
  buy_in.exercises.build(movement: handstand_hold, position: 1, reps: 1, duration_seconds: 56, notes: 'Each partner; or a 56-second wall sit.')
  segment = workout.segments.build(position: 2)
  segment.exercises.build(movement: burpee, position: 1, reps: 56, notes: 'Each partner.')
  segment.exercises.build(movement: flutter_kick, position: 2, reps: 56, notes: 'Each partner; 4-count.')
  segment.exercises.build(movement: walking_lunge, position: 3, reps: 56, notes: 'Each partner.')
  segment.exercises.build(movement: hand_release_push_up, position: 4, reps: 56, notes: 'Each partner.')
  segment.exercises.build(movement: air_squat, position: 5, reps: 56, notes: 'Each partner.')
  cash_out = workout.segments.build(position: 7, name: 'Cash-out')
  cash_out.exercises.build(movement: run, position: 1, reps: 1, distance: 5600, distance_unit: :meter, notes: 'Run together.')
end

# ==============================================================================
# Maxton
# 13 rounds for time: 8 strict pull-ups, 26 box step-ups, 21 burpees
Workout.find_or_create_by(name: 'Maxton') do |workout|
  segment = workout.segments.build(rounds: 13, position: 1)
  workout.score_type = :time
  workout.notes = 'Wear a 14-lb (♀) / 20-lb (♂) weight vest.'
  segment.exercises.build(movement: strict_pull_up, position: 1, reps: 8)
  segment.exercises.build(movement: box_step_up, position: 2, reps: 26, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: burpee, position: 3, reps: 21)
end

# ==============================================================================
# McCartney
# For time in teams of 3: 2,000-meter row, 14 dumbbell thrusters (35/50 lb),
# 34 kettlebell swings (53/70 lb), 484 double-unders, 108 burpees, 2,000-meter row,
# 18 deadlifts (155/225 lb)
Workout.find_or_create_by(name: 'McCartney') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  workout.team_size = 3
  workout.notes = 'As a 3-person team.'
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 2000, distance_unit: :meter)
  segment.exercises.build(movement: dumbbell_thruster, position: 2, reps: 14, female_load: 35, male_load: 50, load_unit: :lb, implement_count: 2)
  segment.exercises.build(movement: kettlebell_swing, position: 3, reps: 34, female_load: 53, male_load: 70, load_unit: :lb)
  segment.exercises.build(movement: double_under, position: 4, reps: 484)
  segment.exercises.build(movement: burpee, position: 5, reps: 108)
  segment.exercises.build(movement: row, position: 6, reps: 1, distance: 2000, distance_unit: :meter)
  segment.exercises.build(movement: deadlift, position: 7, reps: 18, female_load: 155, male_load: 225, load_unit: :lb)
end

# ==============================================================================
# McCluskey
# 3 rounds for time: 9 muscle-ups, 15 burpee pull-ups, 21 pull-ups, run 800m
Workout.find_or_create_by(name: 'McCluskey') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: muscle_up, position: 1, reps: 9)
  segment.exercises.build(movement: burpee_pull_up, position: 2, reps: 15)
  segment.exercises.build(movement: pull_up, position: 3, reps: 21)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 800, distance_unit: :meter)
end

# ==============================================================================
# McGhee
# AMRAP in 30 minutes: 5 deadlifts, 13 push-ups, 9 box jumps
Workout.find_or_create_by(name: 'McGhee') do |workout|
  segment = workout.segments.build(time_seconds: 1800, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: deadlift, position: 1, reps: 5, female_load: 185, male_load: 275, load_unit: :lb)
  segment.exercises.build(movement: push_up, position: 2, reps: 13)
  segment.exercises.build(movement: box_jump, position: 3, reps: 9, female_distance: 20, male_distance: 24, distance_unit: :inch)
end

# ==============================================================================
# Meadows
# For time: 20 muscle-ups, 25 inverted ring lowers, 30 ring handstand push-ups, 35 ring rows, 40 ring push-ups
Workout.find_or_create_by(name: 'Meadows') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: muscle_up, position: 1, reps: 20)
  segment.exercises.build(movement: inverted_ring_lower, position: 2, reps: 25, notes: 'Lower slowly with straight body and arms.')
  segment.exercises.build(movement: ring_handstand_push_up, position: 3, reps: 30)
  segment.exercises.build(movement: ring_row, position: 4, reps: 35)
  segment.exercises.build(movement: ring_push_up, position: 5, reps: 40)
end

# ==============================================================================
# Michael
# 3 rounds for time: run 800m, 50 back extensions, 50 sit-ups
Workout.find_or_create_by(name: 'Michael') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: back_extensions, position: 2, reps: 50)
  segment.exercises.build(movement: sit_up, position: 3, reps: 50)
end

# ==============================================================================
# Miron
# 5 rounds for time: 800m run, 23 back squats, 13 deadlifts
Workout.find_or_create_by(name: 'Miron') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: back_squat, position: 2, reps: 23)
  segment.exercises.build(movement: deadlift, position: 3, reps: 13)
end

# ==============================================================================
# Monti
# 5 rounds for time: 50 barbell step-ups, 15 cleans, 50 barbell step-ups, 10 snatches
Workout.find_or_create_by(name: 'Monti') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: barbell_step_up, position: 1, reps: 50, female_load: 35, male_load: 45, load_unit: :lb, female_distance: 20,
                          male_distance: 20, distance_unit: :inch)
  segment.exercises.build(movement: clean, position: 2, reps: 15, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: barbell_step_up, position: 3, reps: 50, female_load: 35, male_load: 45, load_unit: :lb, female_distance: 20,
                          male_distance: 20, distance_unit: :inch)
  segment.exercises.build(movement: snatch, position: 4, reps: 10, female_load: 95, male_load: 135, load_unit: :lb)
end

# ==============================================================================
# Moon
# 7 rounds for time: 10 dumbbell hang split snatches (R), 1 rope climb to 15 feet,
# 10 dumbbell hang split snatches (L), 1 rope climb. Alternate feet on the split snatches.
Workout.find_or_create_by(name: 'Moon') do |workout|
  segment = workout.segments.build(rounds: 7, position: 1)
  workout.score_type = :time
  workout.notes = 'Alternate feet on the split snatches.'
  segment.exercises.build(movement: dumbbell_hang_split_snatch, position: 1, reps: 10, notes: 'Right arm.', female_load: 30, male_load: 40, load_unit: :lb)
  segment.exercises.build(movement: rope_climb, position: 2, reps: 1, distance: 15, distance_unit: :foot)
  segment.exercises.build(movement: dumbbell_hang_split_snatch, position: 3, reps: 10, notes: 'Left arm.', female_load: 30, male_load: 40, load_unit: :lb)
  segment.exercises.build(movement: rope_climb, position: 4, reps: 1, distance: 15, distance_unit: :foot)
end

# ==============================================================================
# Moore
# AMRAP in 20 minutes: 1 rope climb to 15 feet, run 400m, max-rep handstand push-ups
Workout.find_or_create_by(name: 'Moore') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :round
  segment.exercises.build(movement: rope_climb, position: 1, reps: 1, distance: 15, distance_unit: :foot)
  segment.exercises.build(movement: run, position: 2, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: handstand_push_up, position: 3, reps: 0)
end

# ==============================================================================
# Morrison
# 50-40-30-20-10 reps for time: wall-ball shots, box jumps, kettlebell swings
Workout.find_or_create_by(name: 'Morrison') do |workout|
  segment = workout.segments.build(interval_scheme: '50-40-30-20-10', position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: wall_ball_shot, position: 1, reps: 1, distance: 9, distance_unit: :foot, female_load: 14, male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 2, reps: 1, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: kettlebell_swing, position: 3, reps: 1, female_load: 35, male_load: 53, load_unit: :lb)
end

# ==============================================================================
# Mr. Joshua
# 5 rounds for time: run 400m, 30 GHD sit-ups, 15 deadlifts
Workout.find_or_create_by(name: 'Mr. Joshua') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: ghd_sit_up, position: 2, reps: 30)
  segment.exercises.build(movement: deadlift, position: 3, reps: 15, female_load: 175, male_load: 250, load_unit: :lb)
end

# ==============================================================================
# Muller
# For time: run 1,000m, 710m plate carry; 5 rounds (13 burpee pull-ups, 13 deadlifts); 710m plate carry, run 1,000m
Workout.find_or_create_by(name: 'Muller') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 1000, distance_unit: :meter)
  segment.exercises.build(movement: plate_carry, position: 2, reps: 1, distance: 710, distance_unit: :meter, female_load: 25, male_load: 45, load_unit: :lb)
  rounds = workout.segments.build(rounds: 5, position: 3)
  rounds.exercises.build(movement: burpee_pull_up, position: 1, reps: 13)
  rounds.exercises.build(movement: deadlift, position: 2, reps: 13, female_load: 155, male_load: 225, load_unit: :lb)
  segment = workout.segments.build(position: 4)
  segment.exercises.build(movement: plate_carry, position: 1, reps: 1, distance: 710, distance_unit: :meter, female_load: 25, male_load: 45, load_unit: :lb)
  segment.exercises.build(movement: run, position: 2, reps: 1, distance: 1000, distance_unit: :meter)
end

# ==============================================================================
# Murph
# For time: 1-mile run, 100 pull-ups, 200 push-ups, 300 squats, 1-mile run. Partition as needed.
Workout.find_or_create_by(name: 'Murph') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  workout.notes = 'Partition the pull-ups, push-ups, and squats as needed.'
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 1600, distance_unit: :meter)
  segment.exercises.build(movement: pull_up, position: 2, reps: 100)
  segment.exercises.build(movement: push_up, position: 3, reps: 200)
  segment.exercises.build(movement: air_squat, position: 4, reps: 300)
  segment.exercises.build(movement: run, position: 5, reps: 1, distance: 1600, distance_unit: :meter)
end

# ==============================================================================
# Nate
# AMRAP in 20 minutes: 2 muscle-ups, 4 handstand push-ups, 8 kettlebell swings
Workout.find_or_create_by(name: 'Nate') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: muscle_up, position: 1, reps: 2)
  segment.exercises.build(movement: handstand_push_up, position: 2, reps: 4)
  segment.exercises.build(movement: kettlebell_swing, position: 3, reps: 8, female_load: 53, male_load: 70, load_unit: :lb)
end

# ==============================================================================
# Ned
# 7 rounds for time: 11 back squats, 1,000m row
Workout.find_or_create_by(name: 'Ned') do |workout|
  segment = workout.segments.build(rounds: 7, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: back_squat, position: 1, reps: 11)
  segment.exercises.build(movement: row, position: 2, reps: 1, distance: 1000, distance_unit: :meter)
end

# ==============================================================================
# Nick
# 12 rounds for time: 10 dumbbell hang squat cleans, 6 handstand push-ups on dumbbells
Workout.find_or_create_by(name: 'Nick') do |workout|
  segment = workout.segments.build(rounds: 12, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: dumbbell_hang_squat_clean, position: 1, reps: 10, female_load: 30, male_load: 45, load_unit: :lb, implement_count: 2)
  segment.exercises.build(movement: handstand_push_up, position: 2, reps: 6, notes: 'On dumbbells.')
end

# ==============================================================================
# Nickman
# 10 rounds for time: 200m farmers carry, 10 weighted pull-ups, 20 dumbbell alternating power snatches
Workout.find_or_create_by(name: 'Nickman') do |workout|
  segment = workout.segments.build(rounds: 10, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: farmers_carry, position: 1, reps: 1, distance: 200, distance_unit: :meter, female_load: 40, male_load: 55, load_unit: :lb)
  segment.exercises.build(movement: weighted_pull_up, position: 2, reps: 10, female_load: 20, male_load: 35, load_unit: :lb)
  segment.exercises.build(movement: dumbbell_power_snatch, position: 3, reps: 20, notes: 'Alternating arms.', female_load: 40, male_load: 55, load_unit: :lb)
end

# ==============================================================================
# Northrup
# For time: 26 barbell back-rack step-ups; 3 rounds (17 power cleans, 19 sit-ups, 21 deadlifts); 31-calorie row
Workout.find_or_create_by(name: 'Northrup') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: barbell_back_rack_step_up, position: 1, reps: 26, female_distance: 20, male_distance: 24, distance_unit: :inch,
                          female_load: 65, male_load: 95, load_unit: :lb)
  rounds = workout.segments.build(rounds: 3, position: 2)
  rounds.exercises.build(movement: power_clean, position: 1, reps: 17, female_load: 65, male_load: 95, load_unit: :lb)
  rounds.exercises.build(movement: sit_up, position: 2, reps: 19)
  rounds.exercises.build(movement: deadlift, position: 3, reps: 21, female_load: 65, male_load: 95, load_unit: :lb)
  segment = workout.segments.build(position: 3)
  segment.exercises.build(movement: row, position: 1, reps: 1, calories: 31)
end

# ==============================================================================
# Nukes
# 8 min: 1-mile run, max deadlifts; then 10 min: 1-mile run, max power cleans; then 12 min: 1-mile run, max overhead squats. No rest.
Workout.find_or_create_by(name: 'Nukes') do |workout|
  workout.score_type = :rep
  workout.notes = 'Do not rest between rounds.'
  station_one = workout.segments.build(position: 1, name: '8-minute station', time_seconds: 480)
  station_one.exercises.build(movement: run, position: 1, reps: 1, distance: 1600, distance_unit: :meter)
  station_one.exercises.build(movement: deadlift, position: 2, reps: 0, female_load: 205, male_load: 315, load_unit: :lb)
  station_two = workout.segments.build(position: 2, name: '10-minute station', time_seconds: 600)
  station_two.exercises.build(movement: run, position: 1, reps: 1, distance: 1600, distance_unit: :meter)
  station_two.exercises.build(movement: power_clean, position: 2, reps: 0, female_load: 155, male_load: 225, load_unit: :lb)
  station_three = workout.segments.build(position: 3, name: '12-minute station', time_seconds: 720)
  station_three.exercises.build(movement: run, position: 1, reps: 1, distance: 1600, distance_unit: :meter)
  station_three.exercises.build(movement: overhead_squat, position: 2, reps: 0, female_load: 95, male_load: 135, load_unit: :lb)
end

# ==============================================================================
# Nunez
# For time: 800m run, 60 burpee box jump-overs, 50 pull-ups, 40 squats; 600m run, 30 burpee box jump-overs,
# 25 chest-to-bar pull-ups, 20 squats; 400m run, 15 burpee box jump-overs, 12 bar muscle-ups, 10 squat cleans
Workout.find_or_create_by(name: 'Nunez') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: burpee_box_jump_over, position: 2, reps: 60, female_distance: 20, male_distance: 20, distance_unit: :inch)
  segment.exercises.build(movement: pull_up, position: 3, reps: 50)
  segment.exercises.build(movement: air_squat, position: 4, reps: 40, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: run, position: 5, reps: 1, distance: 600, distance_unit: :meter)
  segment.exercises.build(movement: burpee_box_jump_over, position: 6, reps: 30, female_distance: 20, male_distance: 20, distance_unit: :inch)
  segment.exercises.build(movement: chest_to_bar_pull_up, position: 7, reps: 25)
  segment.exercises.build(movement: air_squat, position: 8, reps: 20, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: run, position: 9, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: burpee_box_jump_over, position: 10, reps: 15, female_distance: 20, male_distance: 20, distance_unit: :inch)
  segment.exercises.build(movement: bar_muscle_up, position: 11, reps: 12)
  segment.exercises.build(movement: clean_squat, position: 12, reps: 10, female_load: 155, male_load: 225, load_unit: :lb)
end

# ==============================================================================
# Nutts
# For time: 10 handstand push-ups, 15 deadlifts, 25 box jumps, 50 pull-ups, 100 wall-ball shots,
# 200 double-unders, 400m run with a plate
Workout.find_or_create_by(name: 'Nutts') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: handstand_push_up, position: 1, reps: 10)
  segment.exercises.build(movement: deadlift, position: 2, reps: 15, female_load: 175, male_load: 250, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 3, reps: 25, female_distance: 24, male_distance: 30, distance_unit: :inch)
  segment.exercises.build(movement: pull_up, position: 4, reps: 50)
  segment.exercises.build(movement: wall_ball_shot, position: 5, reps: 100, female_load: 14, male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: double_under, position: 6, reps: 200)
  segment.exercises.build(movement: run, position: 7, reps: 1, distance: 400, distance_unit: :meter, notes: 'Carry a plate.', female_load: 25, male_load: 45,
                          load_unit: :lb)
end

# ==============================================================================
# ODA 7313
# 7 rounds for time: 300m jog, 10 left-arm DB thrusters, 10 right-arm DB thrusters, 7 strict pull-ups
Workout.find_or_create_by(name: 'ODA 7313') do |workout|
  segment = workout.segments.build(rounds: 7, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 300, distance_unit: :meter, notes: 'Jog.')
  segment.exercises.build(movement: dumbbell_thruster, position: 2, reps: 10, notes: 'Left arm.', female_load: 20, male_load: 30, load_unit: :lb)
  segment.exercises.build(movement: dumbbell_thruster, position: 3, reps: 10, notes: 'Right arm.', female_load: 20, male_load: 30, load_unit: :lb)
  segment.exercises.build(movement: strict_pull_up, position: 4, reps: 7)
end

# ==============================================================================
# Omar
# For time: 10 thrusters, 15 bar-facing burpees, 20 thrusters, 25 bar-facing burpees, 30 thrusters, 35 bar-facing burpees
Workout.find_or_create_by(name: 'Omar') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: thruster, position: 1, reps: 10, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: bar_facing_burpee, position: 2, reps: 15)
  segment.exercises.build(movement: thruster, position: 3, reps: 20, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: bar_facing_burpee, position: 4, reps: 25)
  segment.exercises.build(movement: thruster, position: 5, reps: 30, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: bar_facing_burpee, position: 6, reps: 35)
end

# ==============================================================================
# Otis
# AMRAP in 15 minutes, ascending ladder: 1 back squat, 1 shoulder press, 1 deadlift; then 2 of each;
# then 3 of each; etc. Use 1 1/2 body weight for the squats and deadlifts and 3/4 body weight for the presses.
Workout.find_or_create_by(name: 'Otis') do |workout|
  segment = workout.segments.build(time_seconds: 900, position: 1)
  workout.score_type = :rep
  workout.ladder_step = 1
  workout.notes = 'Ascending ladder: 1 rep of each movement, then 2 of each, then 3 of each, and so on ' \
                  'for as long as 15 minutes allow. Post total reps.'
  segment.exercises.build(movement: back_squat, position: 1, reps: 1, notes: '1 1/2 body weight')
  segment.exercises.build(movement: shoulder_press, position: 2, reps: 1, notes: '3/4 body weight')
  segment.exercises.build(movement: deadlift, position: 3, reps: 1, notes: '1 1/2 body weight')
end

# ==============================================================================
# Partner Weston
# 5 rounds for time with a partner: 1,000-meter row, 200-meter dumbbell farmers carry,
# 50-meter single-dumbbell waiters walk (right arm), 50-meter single-dumbbell waiters
# walk (left arm). One partner works at a time. (35/45 lb)
Workout.find_or_create_by(name: 'Partner Weston') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  workout.team_size = 2
  workout.notes = 'With a partner; one partner works at a time.'
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 1000, distance_unit: :meter)
  segment.exercises.build(movement: dumbbell_farmers_carry, position: 2, reps: 1, distance: 200, distance_unit: :meter, female_load: 35, male_load: 45,
                          load_unit: :lb, implement_count: 2)
  segment.exercises.build(movement: dumbbell_waiters_walk, position: 3, reps: 1, distance: 50, distance_unit: :meter, female_load: 35, male_load: 45,
                          load_unit: :lb, notes: 'Right arm.')
  segment.exercises.build(movement: dumbbell_waiters_walk, position: 4, reps: 1, distance: 50, distance_unit: :meter, female_load: 35, male_load: 45,
                          load_unit: :lb, notes: 'Left arm.')
end

# ==============================================================================
# Pat
# For time: run 800m w/ plate; 14 rounds (5 strict pull-ups, 4 burpee box jumps, 3 cleans); run 800m w/ plate
Workout.find_or_create_by(name: 'Pat') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter, notes: 'Carry a plate.', female_load: 25, male_load: 25,
                          load_unit: :lb)
  rounds = workout.segments.build(rounds: 14, position: 2)
  rounds.exercises.build(movement: strict_pull_up, position: 1, reps: 5)
  rounds.exercises.build(movement: burpee_box_jump, position: 2, reps: 4, female_distance: 20, male_distance: 24, distance_unit: :inch)
  rounds.exercises.build(movement: clean, position: 3, reps: 3, female_load: 125, male_load: 185, load_unit: :lb)
  segment = workout.segments.build(position: 3)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter, notes: 'Carry a plate.', female_load: 25, male_load: 25,
                          load_unit: :lb)
end

# ==============================================================================
# Paul
# 5 rounds for time: 50 double-unders, 35 knees-to-elbows, 20-yard overhead walk
Workout.find_or_create_by(name: 'Paul') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: double_under, position: 1, reps: 50)
  segment.exercises.build(movement: knees_to_elbows, position: 2, reps: 35)
  segment.exercises.build(movement: overhead_walk, position: 3, reps: 1, distance: 60, distance_unit: :foot, notes: '20-yard overhead walk.', female_load: 125,
                          male_load: 185, load_unit: :lb)
end

# ==============================================================================
# Paul Pena
# 7 rounds, each for time: 100m sprint, 19 kettlebell swings, 10 burpee box jumps. Rest 3 minutes between rounds.
Workout.find_or_create_by(name: 'Paul Pena') do |workout|
  segment = workout.segments.build(rounds: 7, position: 1)
  workout.score_type = :time
  workout.notes = 'Each round is for time. Rest 3 minutes between rounds.'
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 100, distance_unit: :meter, notes: 'Sprint.')
  segment.exercises.build(movement: kettlebell_swing, position: 2, reps: 19, female_load: 53, male_load: 70, load_unit: :lb)
  segment.exercises.build(movement: burpee_box_jump, position: 3, reps: 10, female_distance: 20, male_distance: 24, distance_unit: :inch)
end

# ==============================================================================
# Peyton
# AMRAP in 20 minutes: 10 chest-to-bar pull-ups, 10 dumbbell thrusters (40 double-unders every 2 min,
# including 0:00). At the 20:00 mark, run 2 miles.
Workout.find_or_create_by(name: 'Peyton') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :round
  workout.notes = 'Stop and perform 40 double-unders every 2 minutes, including at 0:00. ' \
                  'At the 20:00 mark, complete a 2-mile run.'
  segment.exercises.build(movement: chest_to_bar_pull_up, position: 1, reps: 10)
  segment.exercises.build(movement: dumbbell_thruster, position: 2, reps: 10)
end

# ==============================================================================
# Pheezy
# 3 rounds for time: 5 front squats, 18 pull-ups, 5 deadlifts, 18 toes-to-bars, 5 push jerks, 18 hand-release push-ups
Workout.find_or_create_by(name: 'Pheezy') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: front_squat, position: 1, reps: 5, female_load: 115, male_load: 165, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 2, reps: 18)
  segment.exercises.build(movement: deadlift, position: 3, reps: 5, female_load: 155, male_load: 225, load_unit: :lb)
  segment.exercises.build(movement: toes_to_bar, position: 4, reps: 18)
  segment.exercises.build(movement: push_jerk, position: 5, reps: 5, female_load: 115, male_load: 165, load_unit: :lb)
  segment.exercises.build(movement: hand_release_push_up, position: 6, reps: 18)
end

# ==============================================================================
# Pike
# 5 rounds for time: 20 thrusters, 10 strict ring dips, 20 push-ups, 10 strict handstand push-ups, 50m bear crawl
Workout.find_or_create_by(name: 'Pike') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: thruster, position: 1, reps: 20, female_load: 55, male_load: 75, load_unit: :lb)
  segment.exercises.build(movement: ring_dip, position: 2, reps: 10, notes: 'Strict.')
  segment.exercises.build(movement: push_up, position: 3, reps: 20)
  segment.exercises.build(movement: strict_handstand_push_up, position: 4, reps: 10)
  segment.exercises.build(movement: bear_crawl, position: 5, reps: 1, distance: 50, distance_unit: :meter)
end

# ==============================================================================
# Pikey
# For time: run 400m, 12 burpee bar muscle-ups, 15 squat snatches, run 800m, 12 burpee bar muscle-ups,
# 20 clean and jerks, run 800m, 12 burpee bar muscle-ups, 18 thrusters, run 400m
Workout.find_or_create_by(name: 'Pikey') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: burpee_bar_muscle_up, position: 2, reps: 12)
  segment.exercises.build(movement: squat_snatch, position: 3, reps: 15, female_load: 105, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: burpee_bar_muscle_up, position: 5, reps: 12)
  segment.exercises.build(movement: clean_and_jerk, position: 6, reps: 20, female_load: 105, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: run, position: 7, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: burpee_bar_muscle_up, position: 8, reps: 12)
  segment.exercises.build(movement: thruster, position: 9, reps: 18, female_load: 105, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: run, position: 10, reps: 1, distance: 400, distance_unit: :meter)
end

# ==============================================================================
# PK
# 5 rounds for time: 10 back squats, 10 deadlifts, 400m sprint. Rest 2 minutes between rounds.
Workout.find_or_create_by(name: 'PK') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  workout.notes = 'Rest 2 minutes between rounds.'
  segment.exercises.build(movement: back_squat, position: 1, reps: 10, female_load: 155, male_load: 225, load_unit: :lb)
  segment.exercises.build(movement: deadlift, position: 2, reps: 10, female_load: 185, male_load: 275, load_unit: :lb)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 400, distance_unit: :meter, notes: 'Sprint.')
end

# ==============================================================================
# Rahoi
# AMRAP in 12 minutes: 12 box jumps, 6 thrusters, 6 bar-facing burpees
Workout.find_or_create_by(name: 'Rahoi') do |workout|
  segment = workout.segments.build(time_seconds: 720, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: box_jump, position: 1, reps: 12, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: thruster, position: 2, reps: 6, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: bar_facing_burpee, position: 3, reps: 6)
end

# ==============================================================================
# Ralph
# 4 rounds for time: 8 deadlifts, 16 burpees, 3 rope climbs to 15 feet, run 600m
Workout.find_or_create_by(name: 'Ralph') do |workout|
  segment = workout.segments.build(rounds: 4, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: deadlift, position: 1, reps: 8, female_load: 175, male_load: 250, load_unit: :lb)
  segment.exercises.build(movement: burpee, position: 2, reps: 16)
  segment.exercises.build(movement: rope_climb, position: 3, reps: 3, distance: 15, distance_unit: :foot)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 600, distance_unit: :meter)
end

# ==============================================================================
# Randy
# For time: 75 power snatches
Workout.find_or_create_by(name: 'Randy') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: power_snatch, position: 1, reps: 75, female_load: 55, male_load: 75, load_unit: :lb)
end

# ==============================================================================
# Rankel
# AMRAP in 20 minutes: 6 deadlifts, 7 burpee pull-ups, 10 kettlebell swings, 200m run
Workout.find_or_create_by(name: 'Rankel') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: deadlift, position: 1, reps: 6, female_load: 155, male_load: 225, load_unit: :lb)
  segment.exercises.build(movement: burpee_pull_up, position: 2, reps: 7)
  segment.exercises.build(movement: kettlebell_swing, position: 3, reps: 10, female_load: 53, male_load: 70, load_unit: :lb)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 200, distance_unit: :meter)
end

# ==============================================================================
# René
# 7 rounds for time: 400m run, 21 walking lunges, 15 pull-ups, 9 burpees
Workout.find_or_create_by(name: 'René') do |workout|
  segment = workout.segments.build(rounds: 7, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: walking_lunge, position: 2, reps: 21)
  segment.exercises.build(movement: pull_up, position: 3, reps: 15)
  segment.exercises.build(movement: burpee, position: 4, reps: 9)
end

# ==============================================================================
# Restrepo
# 5 rounds for time: 400m run, 7 strict pull-ups, 7 strict handstand push-ups, 20 toes-to-bars,
# 22 alternating dumbbell snatches (35/50 lb), 200m dumbbell carry
Workout.find_or_create_by(name: 'Restrepo') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: strict_pull_up, position: 2, reps: 7)
  segment.exercises.build(movement: strict_handstand_push_up, position: 3, reps: 7)
  segment.exercises.build(movement: toes_to_bar, position: 4, reps: 20)
  segment.exercises.build(movement: dumbbell_power_snatch, position: 5, reps: 22, female_load: 35, male_load: 50, load_unit: :lb, notes: 'Alternating arms.')
  segment.exercises.build(movement: dumbbell_farmers_carry, position: 6, reps: 1, distance: 200, distance_unit: :meter, female_load: 35, male_load: 50,
                          load_unit: :lb, implement_count: 2)
end

# ==============================================================================
# Rich
# For time: 13 squat snatches; 10 rounds (10 pull-ups, 100m sprint); 13 squat cleans
Workout.find_or_create_by(name: 'Rich') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: squat_snatch, position: 1, reps: 13, female_load: 105, male_load: 155, load_unit: :lb)
  rounds = workout.segments.build(rounds: 10, position: 2)
  rounds.exercises.build(movement: pull_up, position: 1, reps: 10)
  rounds.exercises.build(movement: run, position: 2, reps: 1, distance: 100, distance_unit: :meter, notes: 'Sprint.')
  segment = workout.segments.build(position: 3)
  segment.exercises.build(movement: clean_squat, position: 1, reps: 13, female_load: 105, male_load: 155, load_unit: :lb)
end

# ==============================================================================
# Ricky
# AMRAP in 20 minutes: 10 pull-ups, 5 dumbbell deadlifts, 8 push presses
Workout.find_or_create_by(name: 'Ricky') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: pull_up, position: 1, reps: 10)
  segment.exercises.build(movement: dumbbell_deadlift, position: 2, reps: 5, female_load: 50, male_load: 75, load_unit: :lb, implement_count: 2)
  segment.exercises.build(movement: push_press, position: 3, reps: 8, female_load: 95, male_load: 135, load_unit: :lb)
end

# ==============================================================================
# Riley
# For time: run 1.5 miles, 150 burpees, run 1.5 miles
Workout.find_or_create_by(name: 'Riley') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 2400, distance_unit: :meter)
  segment.exercises.build(movement: burpee, position: 2, reps: 150)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 2400, distance_unit: :meter)
end

# ==============================================================================
# RJ
# 5 rounds for time: 800m run, 5 rope climbs to 15 feet, 50 push-ups
Workout.find_or_create_by(name: 'RJ') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: rope_climb, position: 2, reps: 5, distance: 15, distance_unit: :foot)
  segment.exercises.build(movement: push_up, position: 3, reps: 50)
end

# ==============================================================================
# Robbie
# AMRAP in 25 minutes: 8 freestanding handstand push-ups, 1 L-sit rope climb to 15 feet
Workout.find_or_create_by(name: 'Robbie') do |workout|
  segment = workout.segments.build(time_seconds: 1500, position: 1)
  workout.score_type = :round
  segment.exercises.build(movement: freestanding_handstand_push_up, position: 1, reps: 8)
  segment.exercises.build(movement: l_sit_rope_climb, position: 2, reps: 1, distance: 15, distance_unit: :foot)
end

# ==============================================================================
# Rocket
# AMRAP in 30 minutes: 50-yard swim, 10 push-ups, 15 squats
Workout.find_or_create_by(name: 'Rocket') do |workout|
  segment = workout.segments.build(time_seconds: 1800, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: swim, position: 1, reps: 1, distance: 150, distance_unit: :foot, notes: '50-yard swim.')
  segment.exercises.build(movement: push_up, position: 2, reps: 10)
  segment.exercises.build(movement: air_squat, position: 3, reps: 15)
end

# ==============================================================================
# Roney
# 4 rounds for time: 200m run, 11 thrusters, 200m run, 11 push presses, 200m run, 11 bench presses
Workout.find_or_create_by(name: 'Roney') do |workout|
  segment = workout.segments.build(rounds: 4, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 200, distance_unit: :meter)
  segment.exercises.build(movement: thruster, position: 2, reps: 11, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 200, distance_unit: :meter)
  segment.exercises.build(movement: push_press, position: 4, reps: 11, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: run, position: 5, reps: 1, distance: 200, distance_unit: :meter)
  segment.exercises.build(movement: bench_press, position: 6, reps: 11, female_load: 95, male_load: 135, load_unit: :lb)
end

# ==============================================================================
# Roy
# 5 rounds for time: 15 deadlifts, 20 box jumps, 25 pull-ups
Workout.find_or_create_by(name: 'Roy') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: deadlift, position: 1, reps: 15, female_load: 155, male_load: 225, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 2, reps: 20, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: pull_up, position: 3, reps: 25)
end

# ==============================================================================
# Ryan
# 5 rounds for time: 7 muscle-ups, 21 burpees
Workout.find_or_create_by(name: 'Ryan') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: muscle_up, position: 1, reps: 7)
  segment.exercises.build(movement: burpee, position: 2, reps: 21)
end

# ==============================================================================
# Ryan Comas
# For time as a 3-person team: 1,065-foot versa climb (or 1,065-meter row or ski);
# then 10 rounds of 13 deadlifts, 13 pull-ups, 13-calorie row, 13 back squats,
# 13 burpees; then 1,065-foot versa climb (or 1,065-meter row or ski). (165/225 lb)
Workout.find_or_create_by(name: 'Ryan Comas') do |workout|
  workout.score_type = :time
  workout.team_size = 3
  workout.notes = 'As a 3-person team.'
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 1065, distance_unit: :meter, notes: '1,065-foot versa climb, 1,065-meter row, or ski.')
  rounds = workout.segments.build(rounds: 10, position: 2)
  rounds.exercises.build(movement: deadlift, position: 1, reps: 13, female_load: 165, male_load: 225, load_unit: :lb)
  rounds.exercises.build(movement: pull_up, position: 2, reps: 13)
  rounds.exercises.build(movement: row, position: 3, reps: 1, calories: 13)
  rounds.exercises.build(movement: back_squat, position: 4, reps: 13, female_load: 165, male_load: 225, load_unit: :lb)
  rounds.exercises.build(movement: burpee, position: 5, reps: 13)
  segment = workout.segments.build(position: 3)
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 1065, distance_unit: :meter, notes: '1,065-foot versa climb, 1,065-meter row, or ski.')
end

# ==============================================================================
# Ryan SO
# For time: 1,600m run; 4 rounds (9 power cleans, 2 strict pull-ups, 14 burpees);
# 3 rounds (13 box jumps, 13 push-ups, 50 double-unders); 1,600m run
Workout.find_or_create_by(name: 'Ryan SO') do |workout|
  workout.score_type = :time
  workout.notes = 'Wear a 14-lb (♀) / 20-lb (♂) weight vest for the run.'
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 1600, distance_unit: :meter)
  rounds_four = workout.segments.build(rounds: 4, position: 2)
  rounds_four.exercises.build(movement: power_clean, position: 1, reps: 9, female_load: 95, male_load: 135, load_unit: :lb)
  rounds_four.exercises.build(movement: strict_pull_up, position: 2, reps: 2)
  rounds_four.exercises.build(movement: burpee, position: 3, reps: 14)
  rounds_three = workout.segments.build(rounds: 3, position: 3)
  rounds_three.exercises.build(movement: box_jump, position: 1, reps: 13, female_distance: 20, male_distance: 24, distance_unit: :inch)
  rounds_three.exercises.build(movement: push_up, position: 2, reps: 13)
  rounds_three.exercises.build(movement: double_under, position: 3, reps: 50)
  segment = workout.segments.build(position: 4)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 1600, distance_unit: :meter)
end

# ==============================================================================
# Santiago
# 7 rounds for time: 18 dumbbell hang squat cleans, 18 pull-ups, 10 power cleans, 10 handstand push-ups
Workout.find_or_create_by(name: 'Santiago') do |workout|
  segment = workout.segments.build(rounds: 7, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: dumbbell_hang_squat_clean, position: 1, reps: 18, female_load: 20, male_load: 35, load_unit: :lb, implement_count: 2)
  segment.exercises.build(movement: pull_up, position: 2, reps: 18)
  segment.exercises.build(movement: power_clean, position: 3, reps: 10, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: handstand_push_up, position: 4, reps: 10)
end

# ==============================================================================
# Santora
# 3 rounds for reps: 1 min squat cleans, 1 min deadlifts, 1 min burpees, 1 min jerks. Rest 1 minute between rounds.
Workout.find_or_create_by(name: 'Santora') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :rep
  workout.notes = 'Rest 1 minute between rounds.'
  segment.exercises.build(movement: clean_squat, position: 1, reps: 0, duration_seconds: 60, female_load: 105, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: deadlift, position: 2, reps: 0, duration_seconds: 60, female_load: 165, male_load: 245, load_unit: :lb)
  segment.exercises.build(movement: burpee, position: 3, reps: 0, duration_seconds: 60)
  segment.exercises.build(movement: jerk, position: 4, reps: 0, duration_seconds: 60, female_load: 105, male_load: 155, load_unit: :lb)
end

# ==============================================================================
# Schmalls
# For time: run 800m; 2 rounds (50 burpees, 40 pull-ups, 30 single-leg squats, 20 KB swings, 10 HSPU); run 800m
Workout.find_or_create_by(name: 'Schmalls') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  rounds = workout.segments.build(rounds: 2, position: 2)
  rounds.exercises.build(movement: burpee, position: 1, reps: 50)
  rounds.exercises.build(movement: pull_up, position: 2, reps: 40)
  rounds.exercises.build(movement: single_leg_squat_pistol, position: 3, reps: 30)
  rounds.exercises.build(movement: kettlebell_swing, position: 4, reps: 20, female_load: 35, male_load: 53, load_unit: :lb)
  rounds.exercises.build(movement: handstand_push_up, position: 5, reps: 10)
  segment = workout.segments.build(position: 3)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
end

# ==============================================================================
# Scooter
# On a 35-minute clock with a partner: AMRAP in 30 minutes of 30 double-unders,
# 15 pull-ups, 15 push-ups, 100-meter sprint; then 5 minutes to find a 1-rep-max
# partner deadlift. One partner works while the other rests, switching each round.
Workout.find_or_create_by(name: 'Scooter') do |workout|
  workout.score_type = :weight
  workout.team_size = 2
  workout.notes = 'With a partner; one works while the other rests, switching after each full round. ' \
                  'Score the 1-rep-max partner deadlift.'
  amrap = workout.segments.build(position: 1, name: '0:00-30:00 AMRAP', time_seconds: 1800)
  amrap.exercises.build(movement: double_under, position: 1, reps: 30)
  amrap.exercises.build(movement: pull_up, position: 2, reps: 15)
  amrap.exercises.build(movement: push_up, position: 3, reps: 15)
  amrap.exercises.build(movement: run, position: 4, reps: 1, distance: 100, distance_unit: :meter, notes: 'Sprint.')
  max = workout.segments.build(position: 2, name: '30:00-35:00 find a 1-rep-max partner deadlift', time_seconds: 300)
  max.exercises.build(movement: deadlift, position: 1, reps: 1, duration_seconds: 300, load_unit: :lb, notes: 'Partner deadlift; record the max load found.')
end

# ==============================================================================
# Scotty
# AMRAP in 11 minutes: 5 deadlifts, 18 wall-ball shots, 17 burpees over the bar
Workout.find_or_create_by(name: 'Scotty') do |workout|
  segment = workout.segments.build(time_seconds: 660, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: deadlift, position: 1, reps: 5, female_load: 205, male_load: 315, load_unit: :lb)
  segment.exercises.build(movement: wall_ball_shot, position: 2, reps: 18, distance: 9, distance_unit: :foot, female_load: 14, male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: over_the_bar_burpee, position: 3, reps: 17)
end

# ==============================================================================
# Sean
# 10 rounds for time: 11 chest-to-bar pull-ups, 22 front squats
Workout.find_or_create_by(name: 'Sean') do |workout|
  segment = workout.segments.build(rounds: 10, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: chest_to_bar_pull_up, position: 1, reps: 11)
  segment.exercises.build(movement: front_squat, position: 2, reps: 22, female_load: 55, male_load: 75, load_unit: :lb)
end

# ==============================================================================
# Servais
# For time: run 1.5 miles; 8 rounds (19 pull-ups, 19 push-ups, 19 burpees); 400m sandbag carry, 1-mile farmers carry
Workout.find_or_create_by(name: 'Servais') do |workout|
  workout.score_type = :time
  workout.notes = 'Use a heavy sandbag.'
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 2400, distance_unit: :meter)
  rounds = workout.segments.build(rounds: 8, position: 2)
  rounds.exercises.build(movement: pull_up, position: 1, reps: 19)
  rounds.exercises.build(movement: push_up, position: 2, reps: 19)
  rounds.exercises.build(movement: burpee, position: 3, reps: 19)
  segment = workout.segments.build(position: 3)
  segment.exercises.build(movement: sandbag_carry, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: farmers_carry, position: 2, reps: 1, distance: 1600, distance_unit: :meter, female_load: 30, male_load: 45, load_unit: :lb)
end

# ==============================================================================
# Severin
# For time: 50 strict pull-ups, 100 hand-release push-ups, run 5K
Workout.find_or_create_by(name: 'Severin') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  workout.notes = 'Wear a 14-lb (♀) / 20-lb (♂) weight vest.'
  segment.exercises.build(movement: strict_pull_up, position: 1, reps: 50)
  segment.exercises.build(movement: hand_release_push_up, position: 2, reps: 100)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 5000, distance_unit: :meter)
end

# ==============================================================================
# Sham
# 7 rounds for time: 11 deadlifts, 100m sprint
Workout.find_or_create_by(name: 'Sham') do |workout|
  segment = workout.segments.build(rounds: 7, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: deadlift, position: 1, reps: 11)
  segment.exercises.build(movement: run, position: 2, reps: 1, distance: 100, distance_unit: :meter, notes: 'Sprint.')
end

# ==============================================================================
# Shawn
# For time: run 5 miles in 5-minute intervals; after each interval, 50 squats and 50 push-ups
Workout.find_or_create_by(name: 'Shawn') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  workout.notes = 'Run in 5-minute intervals; after each 5-minute run interval perform 50 squats and 50 push-ups.'
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 8000, distance_unit: :meter)
  segment.exercises.build(movement: air_squat, position: 2, reps: 50)
  segment.exercises.build(movement: push_up, position: 3, reps: 50)
end

# ==============================================================================
# Ship
# 9 rounds for time: 7 squat cleans, 8 burpee box jumps
Workout.find_or_create_by(name: 'Ship') do |workout|
  segment = workout.segments.build(rounds: 9, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: clean_squat, position: 1, reps: 7, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: burpee_box_jump, position: 2, reps: 8, female_distance: 30, male_distance: 36, distance_unit: :inch)
end

# ==============================================================================
# Sisson
# AMRAP in 20 minutes: 1 rope climb to 15 feet, 5 burpees, 200m run
Workout.find_or_create_by(name: 'Sisson') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :rep
  workout.notes = 'Wear a 14-lb (♀) / 20-lb (♂) weight vest.'
  segment.exercises.build(movement: rope_climb, position: 1, reps: 1, distance: 15, distance_unit: :foot)
  segment.exercises.build(movement: burpee, position: 2, reps: 5)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 200, distance_unit: :meter)
end

# ==============================================================================
# Small
# 3 rounds for time: row 1,000m, 50 burpees, 50 box jumps, run 800m
Workout.find_or_create_by(name: 'Small') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 1000, distance_unit: :meter)
  segment.exercises.build(movement: burpee, position: 2, reps: 50)
  segment.exercises.build(movement: box_jump, position: 3, reps: 50, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 800, distance_unit: :meter)
end

# ==============================================================================
# Smykowski
# For time: run 6K, 60 burpee pull-ups
Workout.find_or_create_by(name: 'Smykowski') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 6000, distance_unit: :meter)
  segment.exercises.build(movement: burpee_pull_up, position: 2, reps: 60)
end

# ==============================================================================
# Spehar
# For time: 100 thrusters, 100 chest-to-bar pull-ups, run 6 miles. Partition as needed.
Workout.find_or_create_by(name: 'Spehar') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  workout.notes = 'Partition the thrusters, pull-ups, and run as needed.'
  segment.exercises.build(movement: thruster, position: 1, reps: 100, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: chest_to_bar_pull_up, position: 2, reps: 100)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 9600, distance_unit: :meter)
end

# ==============================================================================
# Stephen
# 30-25-20-15-10-5 reps for time: GHD sit-ups, back extensions, knees-to-elbows, stiff-legged deadlifts
Workout.find_or_create_by(name: 'Stephen') do |workout|
  segment = workout.segments.build(interval_scheme: '30-25-20-15-10-5', position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: ghd_sit_up, position: 1, reps: 1)
  segment.exercises.build(movement: back_extensions, position: 2, reps: 1)
  segment.exercises.build(movement: knees_to_elbows, position: 3, reps: 1)
  segment.exercises.build(movement: stiff_legged_deadlift, position: 4, reps: 1, female_load: 65, male_load: 95, load_unit: :lb)
end

# ==============================================================================
# Strange
# 8 rounds for time: 600m run, 11 weighted pull-ups, 11 walking lunges with two kettlebells, 11 kettlebell thrusters
Workout.find_or_create_by(name: 'Strange') do |workout|
  segment = workout.segments.build(rounds: 8, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 600, distance_unit: :meter)
  segment.exercises.build(movement: weighted_pull_up, position: 2, reps: 11, female_load: 35, male_load: 53, load_unit: :lb)
  segment.exercises.build(movement: walking_lunge, position: 3, reps: 11, notes: 'With two kettlebells.', female_load: 35, male_load: 53, load_unit: :lb)
  segment.exercises.build(movement: kettlebell_thruster, position: 4, reps: 11, female_load: 35, male_load: 53, load_unit: :lb, implement_count: 2)
end

# ==============================================================================
# T
# 5 rounds for time: 100m sprint, 10 squat clean thrusters, 15 kettlebell swings, 100m sprint. Rest 2 minutes.
Workout.find_or_create_by(name: 'T') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  workout.notes = 'Rest 2 minutes between rounds.'
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 100, distance_unit: :meter, notes: 'Sprint.')
  segment.exercises.build(movement: squat_clean_thruster, position: 2, reps: 10)
  segment.exercises.build(movement: kettlebell_swing, position: 3, reps: 15, female_load: 75, male_load: 75, load_unit: :lb)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 100, distance_unit: :meter, notes: 'Sprint.')
end

# ==============================================================================
# T.J.
# For time: 10 bench presses, 10 strict pull-ups, max-set thrusters. Repeat the triplet until 100 thrusters.
Workout.find_or_create_by(name: 'T.J.') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  workout.notes = 'Repeat the triplet (10 bench presses, 10 strict pull-ups, a max set of thrusters) ' \
                  'until you have completed 100 thrusters total.'
  segment.exercises.build(movement: bench_press, position: 1, reps: 10, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: strict_pull_up, position: 2, reps: 10)
  segment.exercises.build(movement: thruster, position: 3, reps: 100, notes: 'Max-set each round; 100 total.', female_load: 95, male_load: 135, load_unit: :lb)
end

# ==============================================================================
# T.U.P.
# 15-12-9-6-3 reps for time: power cleans, pull-ups, front squats, pull-ups
Workout.find_or_create_by(name: 'T.U.P.') do |workout|
  segment = workout.segments.build(interval_scheme: '15-12-9-6-3', position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: power_clean, position: 1, reps: 1, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 2, reps: 1)
  segment.exercises.build(movement: front_squat, position: 3, reps: 1, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 4, reps: 1)
end

# ==============================================================================
# Tama
# For time: 800m single-arm barbell farmers carry (w1), 31 toes-to-bars, 31 push-ups, 31 front squats,
# 400m single-arm carry (w2), 31 toes-to-bars, 31 push-ups, 31 hang power cleans, 200m single-arm carry (w3)
Workout.find_or_create_by(name: 'Tama') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: farmers_carry, position: 1, reps: 1, distance: 800, distance_unit: :meter, notes: 'Single-arm barbell, weight 1.',
                          female_load: 35, male_load: 45, load_unit: :lb)
  segment.exercises.build(movement: toes_to_bar, position: 2, reps: 31)
  segment.exercises.build(movement: push_up, position: 3, reps: 31)
  segment.exercises.build(movement: front_squat, position: 4, reps: 31, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: farmers_carry, position: 5, reps: 1, distance: 400, distance_unit: :meter, notes: 'Single-arm barbell, weight 2.',
                          female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: toes_to_bar, position: 6, reps: 31)
  segment.exercises.build(movement: push_up, position: 7, reps: 31)
  segment.exercises.build(movement: hang_power_clean, position: 8, reps: 31, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: farmers_carry, position: 9, reps: 1, distance: 200, distance_unit: :meter, notes: 'Single-arm barbell, weight 3.',
                          female_load: 95, male_load: 135, load_unit: :lb)
end

# ==============================================================================
# Taylor
# 4 rounds for time: 400m run, 5 burpee muscle-ups
Workout.find_or_create_by(name: 'Taylor') do |workout|
  segment = workout.segments.build(rounds: 4, position: 1)
  workout.score_type = :time
  workout.notes = 'Wear a 14-lb (♀) / 20-lb (♂) weight vest.'
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: burpee_muscle_up, position: 2, reps: 5)
end

# ==============================================================================
# Terry
# For time: run 1 mile, 100 push-ups, 100m bear crawl, run 1 mile, 100m bear crawl, 100 push-ups, run 1 mile
Workout.find_or_create_by(name: 'Terry') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 1600, distance_unit: :meter)
  segment.exercises.build(movement: push_up, position: 2, reps: 100)
  segment.exercises.build(movement: bear_crawl, position: 3, reps: 1, distance: 100, distance_unit: :meter)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 1600, distance_unit: :meter)
  segment.exercises.build(movement: bear_crawl, position: 5, reps: 1, distance: 100, distance_unit: :meter)
  segment.exercises.build(movement: push_up, position: 6, reps: 100)
  segment.exercises.build(movement: run, position: 7, reps: 1, distance: 1600, distance_unit: :meter)
end

# ==============================================================================
# The Don
# For time: 66 deadlifts, 66 box jumps, 66 kettlebell swings, 66 knees-to-elbows, 66 sit-ups, 66 pull-ups,
# 66 thrusters, 66 wall-ball shots, 66 burpees, 66 double-unders
Workout.find_or_create_by(name: 'The Don') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: deadlift, position: 1, reps: 66, female_load: 70, male_load: 110, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 2, reps: 66, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: kettlebell_swing, position: 3, reps: 66, female_load: 35, male_load: 53, load_unit: :lb)
  segment.exercises.build(movement: knees_to_elbows, position: 4, reps: 66)
  segment.exercises.build(movement: sit_up, position: 5, reps: 66)
  segment.exercises.build(movement: pull_up, position: 6, reps: 66)
  segment.exercises.build(movement: thruster, position: 7, reps: 66, female_load: 35, male_load: 55, load_unit: :lb)
  segment.exercises.build(movement: wall_ball_shot, position: 8, reps: 66, distance: 9, distance_unit: :foot, female_load: 14, male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: burpee, position: 9, reps: 66)
  segment.exercises.build(movement: double_under, position: 10, reps: 66)
end

# ==============================================================================
# The Lyon
# 5 rounds, each for time: 7 squat cleans, 7 shoulder-to-overheads, 7 burpee chest-to-bar pull-ups. Rest 2 minutes.
Workout.find_or_create_by(name: 'The Lyon') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  workout.notes = 'Each round is for time. Rest 2 minutes between rounds. ' \
                  'Ideally use a pull-up bar 6 inches above your max reach.'
  segment.exercises.build(movement: clean_squat, position: 1, reps: 7, female_load: 115, male_load: 165, load_unit: :lb)
  segment.exercises.build(movement: shoulder_to_overhead, position: 2, reps: 7, female_load: 115, male_load: 165, load_unit: :lb)
  segment.exercises.build(movement: burpee_chest_to_bar_pull_up, position: 3, reps: 7)
end

# ==============================================================================
# The Seven
# 7 rounds for time: 7 HSPU, 7 thrusters, 7 knees-to-elbows, 7 deadlifts, 7 burpees, 7 KB swings, 7 pull-ups
Workout.find_or_create_by(name: 'The Seven') do |workout|
  segment = workout.segments.build(rounds: 7, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: handstand_push_up, position: 1, reps: 7)
  segment.exercises.build(movement: thruster, position: 2, reps: 7, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: knees_to_elbows, position: 3, reps: 7)
  segment.exercises.build(movement: deadlift, position: 4, reps: 7, female_load: 165, male_load: 245, load_unit: :lb)
  segment.exercises.build(movement: burpee, position: 5, reps: 7)
  segment.exercises.build(movement: kettlebell_swing, position: 6, reps: 7, female_load: 53, male_load: 70, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 7, reps: 7)
end

# ==============================================================================
# Thompson
# 10 rounds for time: 1 rope climb to 15 feet, 29 back squats, 10m barbell farmers carry. Begin rope climbs seated.
Workout.find_or_create_by(name: 'Thompson') do |workout|
  segment = workout.segments.build(rounds: 10, position: 1)
  workout.score_type = :time
  workout.notes = 'Begin the rope climbs seated on the floor.'
  segment.exercises.build(movement: rope_climb, position: 1, reps: 1, distance: 15, distance_unit: :foot)
  segment.exercises.build(movement: back_squat, position: 2, reps: 29, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: farmers_carry, position: 3, reps: 1, distance: 10, distance_unit: :meter, notes: 'Barbell farmers carry.', female_load: 95,
                          male_load: 135, load_unit: :lb)
end

# ==============================================================================
# Tiff
# On a 25-minute clock: 1.5-mile run, then AMRAP: 11 chest-to-bar pull-ups, 7 hang squat cleans, 7 push presses
Workout.find_or_create_by(name: 'Tiff') do |workout|
  segment = workout.segments.build(time_seconds: 1500, position: 1)
  workout.score_type = :rep
  workout.notes = 'Run 1.5 miles, then AMRAP the triplet in the remaining time.'
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 2400, distance_unit: :meter)
  segment.exercises.build(movement: chest_to_bar_pull_up, position: 2, reps: 11)
  segment.exercises.build(movement: hang_squat_clean, position: 3, reps: 7, female_load: 105, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: push_press, position: 4, reps: 7, female_load: 105, male_load: 155, load_unit: :lb)
end

# ==============================================================================
# Timothy Helton
# For time as a 3-person team: 2,364-meter row; then 10 rounds of 49 wall-ball shots,
# 26 pull-ups, 200-meter run, 8 ring muscle-ups, 40 deadlifts; then build to a heavy
# single back squat for each team member.
# (♀ 14-lb ball to 9 ft, 105-lb deadlift; ♂ 20-lb ball to 10 ft, 155-lb deadlift)
Workout.find_or_create_by(name: 'Timothy Helton') do |workout|
  workout.score_type = :time
  workout.team_size = 3
  workout.notes = 'As a 3-person team. Finish by building to a heavy single back squat for each team member.'
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 2364, distance_unit: :meter)
  rounds = workout.segments.build(rounds: 10, position: 2)
  rounds.exercises.build(movement: wall_ball_shot, position: 1, reps: 49, female_load: 14, male_load: 20, load_unit: :lb, female_distance: 9,
                         male_distance: 10, distance_unit: :foot)
  rounds.exercises.build(movement: pull_up, position: 2, reps: 26)
  rounds.exercises.build(movement: run, position: 3, reps: 1, distance: 200, distance_unit: :meter)
  rounds.exercises.build(movement: ring_muscle_up, position: 4, reps: 8)
  rounds.exercises.build(movement: deadlift, position: 5, reps: 40, female_load: 105, male_load: 155, load_unit: :lb)
  finisher = workout.segments.build(position: 3, name: 'Build to a heavy single back squat (each team member)')
  finisher.exercises.build(movement: back_squat, position: 1, reps: 1, load_unit: :lb, notes: 'Each team member builds to a heavy single; record the load.')
end

# ==============================================================================
# TK
# AMRAP in 20 minutes: 8 strict pull-ups, 8 box jumps, 12 kettlebell swings
Workout.find_or_create_by(name: 'TK') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: strict_pull_up, position: 1, reps: 8)
  segment.exercises.build(movement: box_jump, position: 2, reps: 8, female_distance: 30, male_distance: 36, distance_unit: :inch)
  segment.exercises.build(movement: kettlebell_swing, position: 3, reps: 12, female_load: 53, male_load: 70, load_unit: :lb)
end

# ==============================================================================
# Tom
# AMRAP in 25 minutes: 7 muscle-ups, 11 thrusters, 14 toes-to-bars
Workout.find_or_create_by(name: 'Tom') do |workout|
  segment = workout.segments.build(time_seconds: 1500, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: muscle_up, position: 1, reps: 7)
  segment.exercises.build(movement: thruster, position: 2, reps: 11, female_load: 105, male_load: 155, load_unit: :lb)
  segment.exercises.build(movement: toes_to_bar, position: 3, reps: 14)
end

# ==============================================================================
# Tommy V
# For time: 21 thrusters, 12 rope climbs, 15 thrusters, 9 rope climbs, 9 thrusters, 6 rope climbs
Workout.find_or_create_by(name: 'Tommy V') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: thruster, position: 1, reps: 21, female_load: 75, male_load: 115, load_unit: :lb)
  segment.exercises.build(movement: rope_climb, position: 2, reps: 12, distance: 15, distance_unit: :foot)
  segment.exercises.build(movement: thruster, position: 3, reps: 15, female_load: 75, male_load: 115, load_unit: :lb)
  segment.exercises.build(movement: rope_climb, position: 4, reps: 9, distance: 15, distance_unit: :foot)
  segment.exercises.build(movement: thruster, position: 5, reps: 9, female_load: 75, male_load: 115, load_unit: :lb)
  segment.exercises.build(movement: rope_climb, position: 6, reps: 6, distance: 15, distance_unit: :foot)
end

# ==============================================================================
# Topsy
# AMRAP in 25 minutes: 3 ring muscle-ups, 8 thrusters, 17-calorie row
Workout.find_or_create_by(name: 'Topsy') do |workout|
  segment = workout.segments.build(time_seconds: 1500, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: ring_muscle_up, position: 1, reps: 3)
  segment.exercises.build(movement: thruster, position: 2, reps: 8, female_load: 75, male_load: 115, load_unit: :lb)
  segment.exercises.build(movement: row, position: 3, reps: 1, calories: 17)
end

# ==============================================================================
# TPT9000
# For time: 100m run; 9 rounds (8 burpees, 26 kettlebell swings, 21 wall-ball shots, 100m run)
Workout.find_or_create_by(name: 'TPT9000') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 100, distance_unit: :meter)
  rounds = workout.segments.build(rounds: 9, position: 2)
  rounds.exercises.build(movement: burpee, position: 1, reps: 8)
  rounds.exercises.build(movement: kettlebell_swing, position: 2, reps: 26, female_load: 35, male_load: 44, load_unit: :lb)
  rounds.exercises.build(movement: wall_ball_shot, position: 3, reps: 21, distance: 9, distance_unit: :foot, female_load: 14, male_load: 20, load_unit: :lb)
  rounds.exercises.build(movement: run, position: 4, reps: 1, distance: 100, distance_unit: :meter)
end

# ==============================================================================
# Triple Deuce
# AMRAP in 20 minutes: 22 burpees, 22 air squats, 22 pull-ups, 22 sandbag ground-to-over-the-shoulders, 722m sprint
Workout.find_or_create_by(name: 'Triple Deuce') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: burpee, position: 1, reps: 22)
  segment.exercises.build(movement: air_squat, position: 2, reps: 22)
  segment.exercises.build(movement: pull_up, position: 3, reps: 22)
  segment.exercises.build(movement: sandbag_clean, position: 4, reps: 22, notes: 'Ground-to-over-the-shoulder.', female_load: 40, male_load: 60, load_unit: :lb)
  segment.exercises.build(movement: run, position: 5, reps: 1, distance: 722, distance_unit: :meter, notes: 'Sprint.')
end

# ==============================================================================
# Tully
# 4 rounds for time: swim 200m, 23 dumbbell squat cleans
Workout.find_or_create_by(name: 'Tully') do |workout|
  segment = workout.segments.build(rounds: 4, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: swim, position: 1, reps: 1, distance: 200, distance_unit: :meter)
  segment.exercises.build(movement: dumbbell_squat_clean, position: 2, reps: 23, female_load: 30, male_load: 40, load_unit: :lb, implement_count: 2)
end

# ==============================================================================
# Tumilson
# 8 rounds for time: run 200m, 11 dumbbell burpee deadlifts
Workout.find_or_create_by(name: 'Tumilson') do |workout|
  segment = workout.segments.build(rounds: 8, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 200, distance_unit: :meter)
  segment.exercises.build(movement: dumbbell_burpee_deadlift, position: 2, reps: 11, female_load: 45, male_load: 60, load_unit: :lb, implement_count: 2)
end

# ==============================================================================
# Tyler
# 5 rounds for time: 7 muscle-ups, 21 sumo deadlift high pulls
Workout.find_or_create_by(name: 'Tyler') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: muscle_up, position: 1, reps: 7)
  segment.exercises.build(movement: sumo_deadlift_high_pull, position: 2, reps: 21, female_load: 65, male_load: 95, load_unit: :lb)
end

# ==============================================================================
# Viola
# AMRAP in 20 minutes: 400m run, 11 power snatches, 17 pull-ups, 13 power cleans
Workout.find_or_create_by(name: 'Viola') do |workout|
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: power_snatch, position: 2, reps: 11, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 3, reps: 17)
  segment.exercises.build(movement: power_clean, position: 4, reps: 13, female_load: 65, male_load: 95, load_unit: :lb)
end

# ==============================================================================
# Wade
# For time: run 1,200m; 4 rounds (12 strict pull-ups, 9 strict dips, 6 strict handstand push-ups); run 1,200m
Workout.find_or_create_by(name: 'Wade') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 1200, distance_unit: :meter)
  rounds = workout.segments.build(rounds: 4, position: 2)
  rounds.exercises.build(movement: strict_pull_up, position: 1, reps: 12)
  rounds.exercises.build(movement: dip, position: 2, reps: 9, notes: 'Strict.')
  rounds.exercises.build(movement: strict_handstand_push_up, position: 3, reps: 6)
  segment = workout.segments.build(position: 3)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 1200, distance_unit: :meter)
end

# ==============================================================================
# Walsh
# 4 rounds for time: 22 burpee pull-ups, 22 back squats, 200m run with a plate overhead
Workout.find_or_create_by(name: 'Walsh') do |workout|
  segment = workout.segments.build(rounds: 4, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: burpee_pull_up, position: 1, reps: 22)
  segment.exercises.build(movement: back_squat, position: 2, reps: 22, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 200, distance_unit: :meter, notes: 'Carry a plate overhead.', female_load: 25,
                          male_load: 45, load_unit: :lb)
end

# ==============================================================================
# War Frank
# 3 rounds for time: 25 muscle-ups, 100 squats, 35 GHD sit-ups
Workout.find_or_create_by(name: 'War Frank') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: muscle_up, position: 1, reps: 25)
  segment.exercises.build(movement: air_squat, position: 2, reps: 100)
  segment.exercises.build(movement: ghd_sit_up, position: 3, reps: 35)
end

# ==============================================================================
# Weaver
# 4 rounds for time: 10 L pull-ups, 15 push-ups, 15 chest-to-bar pull-ups, 15 push-ups, 20 pull-ups, 15 push-ups
Workout.find_or_create_by(name: 'Weaver') do |workout|
  segment = workout.segments.build(rounds: 4, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: l_pull_up, position: 1, reps: 10)
  segment.exercises.build(movement: push_up, position: 2, reps: 15)
  segment.exercises.build(movement: chest_to_bar_pull_up, position: 3, reps: 15)
  segment.exercises.build(movement: push_up, position: 4, reps: 15)
  segment.exercises.build(movement: pull_up, position: 5, reps: 20)
  segment.exercises.build(movement: push_up, position: 6, reps: 15)
end

# ==============================================================================
# Wes
# For time: run 800m w/ plate; 14 rounds (5 strict pull-ups, 4 burpee box jumps, 3 cleans); run 800m w/ plate
Workout.find_or_create_by(name: 'Wes') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter, notes: 'Carry a plate.')
  rounds = workout.segments.build(rounds: 14, position: 2)
  rounds.exercises.build(movement: strict_pull_up, position: 1, reps: 5)
  rounds.exercises.build(movement: burpee_box_jump, position: 2, reps: 4)
  rounds.exercises.build(movement: clean, position: 3, reps: 3)
  segment = workout.segments.build(position: 3)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter, notes: 'Carry a plate.')
end

# ==============================================================================
# Wesley
# On a 35-minute clock: 800m run, then AMRAP: 8 box jumps, 6 strict pull-ups, 21-yard walking lunge w/ 45-lb plate overhead
Workout.find_or_create_by(name: 'Wesley') do |workout|
  segment = workout.segments.build(time_seconds: 2100, position: 1)
  workout.score_type = :rep
  workout.notes = 'Run 800 meters, then AMRAP the triplet in the remaining time.'
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: box_jump, position: 2, reps: 8)
  segment.exercises.build(movement: strict_pull_up, position: 3, reps: 6)
  segment.exercises.build(movement: lunge_with_plate_overhead, position: 4, reps: 1, distance: 63, distance_unit: :foot,
                          notes: '21-yard walking lunge with a 45-lb plate overhead.', load: 45, load_unit: :lb)
end

# ==============================================================================
# Weston
# 5 rounds for time: row 1,000m, 200m farmers carry, 50m DB waiters walk (R), 50m DB waiters walk (L)
Workout.find_or_create_by(name: 'Weston') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 1000, distance_unit: :meter)
  segment.exercises.build(movement: farmers_carry, position: 2, reps: 1, distance: 200, distance_unit: :meter, female_load: 30, male_load: 45, load_unit: :lb)
  segment.exercises.build(movement: dumbbell_waiters_walk, position: 3, reps: 1, distance: 50, distance_unit: :meter, notes: 'Right arm.', female_load: 30,
                          male_load: 45, load_unit: :lb)
  segment.exercises.build(movement: dumbbell_waiters_walk, position: 4, reps: 1, distance: 50, distance_unit: :meter, notes: 'Left arm.', female_load: 30,
                          male_load: 45, load_unit: :lb)
end

# ==============================================================================
# White
# 5 rounds for time: 3 rope climbs to 15 feet, 10 toes-to-bars, 21 overhead walking lunges, 400m run
Workout.find_or_create_by(name: 'White') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: rope_climb, position: 1, reps: 3, distance: 15, distance_unit: :foot)
  segment.exercises.build(movement: toes_to_bar, position: 2, reps: 10)
  segment.exercises.build(movement: overhead_walking_lunge, position: 3, reps: 21, female_load: 25, male_load: 45, load_unit: :lb)
  segment.exercises.build(movement: run, position: 4, reps: 1, distance: 400, distance_unit: :meter)
end

# ==============================================================================
# Whitt
# 3 rounds for time: 800m run with medicine ball, 30 wall-ball shots, 30 ball slams with medicine ball
Workout.find_or_create_by(name: 'Whitt') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter, notes: 'Carry a medicine ball.', female_load: 20,
                          male_load: 30, load_unit: :lb)
  segment.exercises.build(movement: wall_ball_shot, position: 2, reps: 30, female_load: 20, male_load: 30, load_unit: :lb)
  segment.exercises.build(movement: slam_ball, position: 3, reps: 30, notes: 'Medicine-ball slams.', female_load: 20, male_load: 30, load_unit: :lb)
end

# ==============================================================================
# Whitten
# 5 rounds for time: 22 kettlebell swings, 22 box jumps, 400m run, 22 burpees, 22 wall-ball shots
Workout.find_or_create_by(name: 'Whitten') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: kettlebell_swing, position: 1, reps: 22, female_load: 53, male_load: 72, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 2, reps: 22, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: burpee, position: 4, reps: 22)
  segment.exercises.build(movement: wall_ball_shot, position: 5, reps: 22, distance: 9, distance_unit: :foot, female_load: 14, male_load: 20, load_unit: :lb)
end

# ==============================================================================
# Willy
# 3 rounds for time: 800m run, 5 front squats, 200m run, 11 chest-to-bar pull-ups, 400m run, 12 kettlebell swings
Workout.find_or_create_by(name: 'Willy') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: front_squat, position: 2, reps: 5, female_load: 155, male_load: 225, load_unit: :lb)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 200, distance_unit: :meter)
  segment.exercises.build(movement: chest_to_bar_pull_up, position: 4, reps: 11)
  segment.exercises.build(movement: run, position: 5, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: kettlebell_swing, position: 6, reps: 12, female_load: 53, male_load: 70, load_unit: :lb)
end

# ==============================================================================
# Wilmot
# 6 rounds for time: 50 squats, 25 ring dips
Workout.find_or_create_by(name: 'Wilmot') do |workout|
  segment = workout.segments.build(rounds: 6, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: air_squat, position: 1, reps: 50)
  segment.exercises.build(movement: ring_dip, position: 2, reps: 25)
end

# ==============================================================================
# Wittman
# 7 rounds for time: 15 kettlebell swings, 15 power cleans, 15 box jumps
Workout.find_or_create_by(name: 'Wittman') do |workout|
  segment = workout.segments.build(rounds: 7, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: kettlebell_swing, position: 1, reps: 15, female_load: 35, male_load: 53, load_unit: :lb)
  segment.exercises.build(movement: power_clean, position: 2, reps: 15, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 3, reps: 15, female_distance: 20, male_distance: 24, distance_unit: :inch)
end

# ==============================================================================
# Woehlke
# 3 rounds, each for time: 4 jerks, 5 front squats, 6 power cleans, 40 pull-ups, 50 push-ups, 60 sit-ups. Rest 3 minutes.
Workout.find_or_create_by(name: 'Woehlke') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  workout.notes = 'Each round is for time. Rest 3 minutes between rounds.'
  segment.exercises.build(movement: jerk, position: 1, reps: 4, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: front_squat, position: 2, reps: 5, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: power_clean, position: 3, reps: 6, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 4, reps: 40)
  segment.exercises.build(movement: push_up, position: 5, reps: 50)
  segment.exercises.build(movement: sit_up, position: 6, reps: 60)
end

# ==============================================================================
# Wood
# 5 rounds for time: 400m run, 10 burpee box jumps, 10 sumo deadlift high pulls, 10 thrusters. Rest 1 minute.
Workout.find_or_create_by(name: 'Wood') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  workout.notes = 'Rest 1 minute between rounds.'
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: burpee_box_jump, position: 2, reps: 10, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: sumo_deadlift_high_pull, position: 3, reps: 10, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: thruster, position: 4, reps: 10, female_load: 65, male_load: 95, load_unit: :lb)
end

# ==============================================================================
# Wyk
# 5 rounds for time: 5 front squats, 5 rope climbs to 15 feet, 400m run with a plate
Workout.find_or_create_by(name: 'Wyk') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: front_squat, position: 1, reps: 5, female_load: 155, male_load: 225, load_unit: :lb)
  segment.exercises.build(movement: rope_climb, position: 2, reps: 5, distance: 15, distance_unit: :foot)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 400, distance_unit: :meter, notes: 'Carry a plate.', female_load: 25, male_load: 45,
                          load_unit: :lb)
end

# ==============================================================================
# Yeti
# For time: 25 pull-ups, 10 muscle-ups, 1.5-mile run, 10 muscle-ups, 25 pull-ups
Workout.find_or_create_by(name: 'Yeti') do |workout|
  segment = workout.segments.build(position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: pull_up, position: 1, reps: 25)
  segment.exercises.build(movement: muscle_up, position: 2, reps: 10)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 2400, distance_unit: :meter)
  segment.exercises.build(movement: muscle_up, position: 4, reps: 10)
  segment.exercises.build(movement: pull_up, position: 5, reps: 25)
end

# ==============================================================================
# Zembiec
# 5 rounds for time: 11 back squats, 7 strict burpee pull-ups, 400m run
Workout.find_or_create_by(name: 'Zembiec') do |workout|
  segment = workout.segments.build(rounds: 5, position: 1)
  workout.score_type = :time
  workout.notes = 'On each burpee pull-up, perform a strict push-up, jump to a bar ideally 12 inches ' \
                  'above your max standing reach, and perform a strict pull-up.'
  segment.exercises.build(movement: back_squat, position: 1, reps: 11, female_load: 125, male_load: 185, load_unit: :lb)
  segment.exercises.build(movement: strict_burpee_pull_up, position: 2, reps: 7)
  segment.exercises.build(movement: run, position: 3, reps: 1, distance: 400, distance_unit: :meter)
end

# ==============================================================================
# Zeus
# 3 rounds for time: 30 wall-ball shots, 30 SDHP, 30 box jumps, 30 push presses, 30-cal row, 30 push-ups, 10 back squats
Workout.find_or_create_by(name: 'Zeus') do |workout|
  segment = workout.segments.build(rounds: 3, position: 1)
  workout.score_type = :time
  segment.exercises.build(movement: wall_ball_shot, position: 1, reps: 30, distance: 9, distance_unit: :foot, female_load: 14, male_load: 20, load_unit: :lb)
  segment.exercises.build(movement: sumo_deadlift_high_pull, position: 2, reps: 30, female_load: 55, male_load: 75, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 3, reps: 30, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: push_press, position: 4, reps: 30, female_load: 55, male_load: 75, load_unit: :lb)
  segment.exercises.build(movement: row, position: 5, reps: 1, calories: 30)
  segment.exercises.build(movement: push_up, position: 6, reps: 30)
  segment.exercises.build(movement: back_squat, position: 7, reps: 10, female_load: 55, male_load: 75, load_unit: :lb)
end

# ==============================================================================
# Zimmerman
# AMRAP in 25 minutes: 11 chest-to-bar pull-ups, 2 deadlifts, 10 handstand push-ups
Workout.find_or_create_by(name: 'Zimmerman') do |workout|
  segment = workout.segments.build(time_seconds: 1500, position: 1)
  workout.score_type = :rep
  segment.exercises.build(movement: chest_to_bar_pull_up, position: 1, reps: 11)
  segment.exercises.build(movement: deadlift, position: 2, reps: 2, female_load: 205, male_load: 315, load_unit: :lb)
  segment.exercises.build(movement: handstand_push_up, position: 3, reps: 10)
end
