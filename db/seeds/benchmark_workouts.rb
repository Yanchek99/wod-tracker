# Fight Gone Bad
# In this workout you move from each of 5 stations after a minute.
# This is a 5-minute round after which a 1-minute break is allowed before repeating.
# We've used this in 3- and 5-round versions. The stations are:
#
# Wall-ball shots, 20-lb. ball, 10-foot target. (reps)
# Sumo deadlift high pulls, 75 lb. (reps)
# Box jumps, 20-inch box (reps)
# Push presses, 75 lb. (reps)
# Row for calories (calories)
# The clock does not reset or stop between exercises.
# On the call of "rotate," the athlete(s) must move to the next station immediately for a good score.
# One point is given for each rep, except on the rower where each calorie is 1 point.
fight_gone_bad = Workout.find_or_create_by(name: 'Fight Gone Bad') do |workout|
  workout.score_type = :rep
  workout.notes = 'In this workout you move from each of 5 stations after a minute. ' \
                  'This is a 5-minute round after which a 1-minute break is allowed before repeating. ' \
                  'The clock does not reset or stop between exercises. ' \
                  'On the call of "rotate," the athlete(s) must move to the next station immediately for a good score. ' \
                  'One point is given for each rep, except on the rower where each calorie is 1 point.'
  segment = workout.segments.build(rounds: 3, time_seconds: 1080, position: 1)
  segment.exercises.build(movement: wall_ball_shot, position: 1, reps: 0, duration_seconds: 60,
                          female_load: 14, male_load: 20, load_unit: :lb, female_distance: 9, male_distance: 10,
                          distance_unit: :foot)
  segment.exercises.build(movement: sumo_deadlift_high_pull, position: 2, reps: 0,
                          duration_seconds: 60, female_load: 55, male_load: 75, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 3, reps: 0, duration_seconds: 60, distance: 20, distance_unit: :inch)
  segment.exercises.build(movement: push_press, position: 4, reps: 0, duration_seconds: 60,
                          female_load: 55, male_load: 75, load_unit: :lb)
  segment.exercises.build(movement: row, position: 5, reps: 1, calories: 0, duration_seconds: 60)
  segment.exercises.build(movement: rest, position: 6, reps: 1, duration_seconds: 60)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: fight_gone_bad).update(posted_at: Date.new(2018, 2, 1))

# ==============================================================================
# The Girl Workouts
# ==============================================================================
# Angie
# For time
# 100 pull-ups
# 100 push-ups
# 100 sit-ups
# 100 squats
angie = Workout.find_or_create_by(name: 'Angie') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: pull_up, position: 1, reps: 100)
  segment.exercises.build(movement: push_up, position: 2, reps: 100)
  segment.exercises.build(movement: sit_up, position: 3, reps: 100)
  segment.exercises.build(movement: air_squat, position: 4, reps: 100)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: angie).update(posted_at: Date.new(2018, 1, 30))

# ==============================================================================
# Barbara
# 5 rounds, each for time
# 20 pull-ups
# 30 push-ups
# 40 sit-ups
# 50 squats
# Rest precisely 3 minutes between each round
barbara = Workout.find_or_create_by(name: 'Barbara') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(rounds: 5, position: 1)
  segment.exercises.build(movement: pull_up, position: 1, reps: 20)
  segment.exercises.build(movement: push_up, position: 2, reps: 30)
  segment.exercises.build(movement: sit_up, position: 3, reps: 40)
  segment.exercises.build(movement: air_squat, position: 4, reps: 50)
  segment.exercises.build(movement: rest, position: 5, reps: 1, duration_seconds: 180)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: barbara).update(posted_at: Date.new(2018, 1, 29))

# ==============================================================================
# Chelsea
# Every minute on the minute for 30 minutes
# 5 pull-ups
# 10 push-ups
# 15 squats
chelsea = Workout.find_or_create_by(name: 'Chelsea') do |workout|
  workout.score_type = :rep
  segment = workout.segments.build(rounds: 30, time_seconds: 1800, position: 1)
  segment.exercises.build(movement: pull_up, position: 1, reps: 5)
  segment.exercises.build(movement: push_up, position: 2, reps: 10)
  segment.exercises.build(movement: air_squat, position: 3, reps: 15)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: chelsea).update(posted_at: Date.new(2018, 1, 28))

# ==============================================================================
# Cindy
# As many rounds as possible in 20 minutes
# 5 pull-ups
# 10 push-ups
# 15 squats
cindy = Workout.find_or_create_by(name: 'Cindy') do |workout|
  workout.score_type = :rep
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  segment.exercises.build(movement: pull_up, position: 1, reps: 5)
  segment.exercises.build(movement: push_up, position: 2, reps: 10)
  segment.exercises.build(movement: air_squat, position: 3, reps: 15)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: cindy).update(posted_at: Date.new(2018, 1, 27))

# ==============================================================================
# Diane
# 21-15-9 reps for time
# 225-lb. deadlifts
# Handstand push-ups
diane = Workout.find_or_create_by(name: 'Diane') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(interval_scheme: '21-15-9', position: 1)
  segment.exercises.build(movement: deadlift, position: 1, reps: 1, female_load: 155, male_load: 225, load_unit: :lb)
  segment.exercises.build(movement: handstand_push_up, position: 2, reps: 1)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: diane).update(posted_at: Date.new(2018, 1, 26))

# ==============================================================================
# Elizabeth
# 21-15-9 reps for time
# 135-lb. cleans
# Ring dips
elizabeth = Workout.find_or_create_by(name: 'Elizabeth') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(interval_scheme: '21-15-9', position: 1)
  segment.exercises.build(movement: clean, position: 1, reps: 1, female_load: 95, male_load: 135, load_unit: :lb)
  segment.exercises.build(movement: ring_dip, position: 2, reps: 1)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: elizabeth).update(posted_at: Date.new(2018, 1, 25))

# ==============================================================================
# Fran
# 21-15-9 reps for time
# 95-lb. thrusters
# Pull-ups
fran = Workout.find_or_create_by(name: 'Fran') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(interval_scheme: '21-15-9', position: 1)
  segment.exercises.build(movement: thruster, position: 1, reps: 1, female_load: 65, male_load: 95, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 2, reps: 1)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: fran).update(posted_at: Date.new(2018, 1, 24))

# ==============================================================================
# Grace
# 30 reps for time
# 135-lb. clean and jerks
grace = Workout.find_or_create_by(name: 'Grace') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: clean_and_jerk, position: 1, reps: 30, female_load: 95, male_load: 135, load_unit: :lb)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: grace).update(posted_at: Date.new(2018, 1, 23))

# ==============================================================================
# Helen
# 3 rounds for time
# Run 400 meters
# 1.5-pood kettlebell swings, 21 reps
# 12 pull-ups
helen = Workout.find_or_create_by(name: 'Helen') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(rounds: 3, position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: kettlebell_swing, position: 2, reps: 21, female_load: 35, male_load: 53, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 3, reps: 12)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: helen).update(posted_at: Date.new(2018, 1, 22))

# ==============================================================================
# Isabel
# 30 reps for time
# 135-lb. snatches
isabel = Workout.find_or_create_by(name: 'Isabel') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: snatch, position: 1, reps: 30, female_load: 95, male_load: 135, load_unit: :lb)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: isabel).update(posted_at: Date.new(2018, 1, 21))

# ==============================================================================
# Jackie
# For time
# Row 1,000 meters
# 45-lb. thrusters, 50 reps
# 30 pull-ups
jackie = Workout.find_or_create_by(name: 'Jackie') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: row, position: 1, reps: 1, distance: 1000, distance_unit: :meter)
  segment.exercises.build(movement: thruster, position: 2, reps: 50, female_load: 35, male_load: 45, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 3, reps: 30)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: jackie).update(posted_at: Date.new(2018, 1, 20))

# ==============================================================================
# Karen
# For time
# 150 wall-ball shots, 20-lb. ball
karen = Workout.find_or_create_by(name: 'Karen') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(position: 1)
  segment.exercises.build(movement: wall_ball_shot, position: 1, reps: 150, female_load: 14,
                          male_load: 20, load_unit: :lb, female_distance: 9, male_distance: 10,
                          distance_unit: :foot)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: karen).update(posted_at: Date.new(2018, 1, 19))

# ==============================================================================
# Linda (a.k.a. 3 Bars of Death)
# 10-9-8-7-6-5-4-3-2-1 reps for time
# 1 1/2 body-weight deadlifts
# Body-weight bench presses
# 3/4 body-weight cleans
linda = Workout.find_or_create_by(name: 'Linda') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(interval_scheme: '10-9-8-7-6-5-4-3-2-1', position: 1)
  segment.exercises.build(movement: deadlift, position: 1, reps: 1, notes: '1 1/2 body weight')
  segment.exercises.build(movement: bench_press, position: 2, reps: 1, notes: 'body weight')
  segment.exercises.build(movement: clean, position: 3, reps: 1, notes: '3/4 body weight')
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: linda).update(posted_at: Date.new(2018, 1, 18))

# ==============================================================================
# Mary
# As many rounds as possible in 20 minutes
# 5 handstand push-ups
# 10 1-legged squats
# 15 pull-ups
mary = Workout.find_or_create_by(name: 'Mary') do |workout|
  workout.score_type = :rep
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  segment.exercises.build(movement: handstand_push_up, position: 1, reps: 5)
  segment.exercises.build(movement: single_leg_squat_pistol, position: 2, reps: 10)
  segment.exercises.build(movement: pull_up, position: 3, reps: 15)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: mary).update(posted_at: Date.new(2018, 1, 17))

# ==============================================================================
# Nancy
# 5 rounds for time
# Run 400 meters
# 95-lb. overhead squats, 15 reps
nancy = Workout.find_or_create_by(name: 'Nancy') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(rounds: 5, position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: overhead_squat, position: 2, reps: 15, female_load: 65, male_load: 95, load_unit: :lb)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: nancy).update(posted_at: Date.new(2018, 1, 16))

# The New Girls Workouts

# ==============================================================================
# Annie
# 50-40-30-20-10 reps for time
# Double-unders
# Sit-ups
annie = Workout.find_or_create_by(name: 'Annie') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(interval_scheme: '50-40-30-20-10', position: 1)
  segment.exercises.build(movement: double_under, position: 1, reps: 1)
  segment.exercises.build(movement: sit_up, position: 2, reps: 1)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: annie).update(posted_at: Date.new(2018, 1, 15))

# ==============================================================================
# Eva
# 5 rounds for time
# Run 800 meters
# 2-pood kettlebell swings, 30 reps
# 30 pull-ups
eva = Workout.find_or_create_by(name: 'Eva') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(rounds: 5, position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  segment.exercises.build(movement: kettlebell_swing, position: 2, reps: 30, female_load: 53, male_load: 70, load_unit: :lb)
  segment.exercises.build(movement: pull_up, position: 3, reps: 30)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: eva).update(posted_at: Date.new(2018, 1, 14))

# ==============================================================================
# Kelly
# 5 rounds for time
# Run 400 meters
# 30 box jumps, 24-inch box
# 30 wall-ball shots, 20-lb. ball
kelly = Workout.find_or_create_by(name: 'Kelly') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(rounds: 5, position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: box_jump, position: 2, reps: 30, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: wall_ball_shot, position: 3, reps: 30, female_load: 14,
                          male_load: 20, load_unit: :lb, female_distance: 9, male_distance: 10,
                          distance_unit: :foot)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: kelly).update(posted_at: Date.new(2018, 1, 13))

# ==============================================================================
# Lynne
# 5 rounds for max reps. There is no time component to this workout,
# although some versions Rx the movements as a couplet.
# Body-weight bench press
# Pull-ups
lynne = Workout.find_or_create_by(name: 'Lynne') do |workout|
  workout.score_type = :rep
  segment = workout.segments.build(rounds: 5, position: 1)
  segment.exercises.build(movement: bench_press, position: 1, reps: 0, notes: 'body weight')
  segment.exercises.build(movement: pull_up, position: 2, reps: 30)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: lynne).update(posted_at: Date.new(2018, 1, 12))

# ==============================================================================
# Nicole
# As many rounds as possible in 20 minutes.
# Note number of pull-ups completed for each round.
# Run 400 meters
# Max-reps pull-ups
nicole = Workout.find_or_create_by(name: 'Nicole') do |workout|
  workout.score_type = :round
  segment = workout.segments.build(time_seconds: 1200, position: 1)
  segment.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  segment.exercises.build(movement: pull_up, position: 2, reps: 0)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: nicole).update(posted_at: Date.new(2018, 1, 11))

# ==============================================================================
# Amanda
# 9-7-5 reps for time
# Muscle-ups
# 135-lb. snatches
amanda = Workout.find_or_create_by(name: 'Amanda') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(interval_scheme: '9-7-5', position: 1)
  segment.exercises.build(movement: muscle_up, position: 1, reps: 1)
  segment.exercises.build(movement: snatch, position: 2, reps: 1, female_load: 95, male_load: 135, load_unit: :lb)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: amanda).update(posted_at: Date.new(2018, 1, 10))

# ==============================================================================
# Gwen
# For load
# Clean and jerk 15-12-9 reps
# Touch and go at floor only. Even a re-grip off the floor is a foul. No dumping.
# Use same load for each set. Rest as needed between sets.
gwen = Workout.find_or_create_by(name: 'Gwen') do |workout|
  workout.score_type = :weight
  segment = workout.segments.build(interval_scheme: '15-12-9', position: 1)
  segment.exercises.build(movement: clean_and_jerk, position: 1, reps: 1, load_unit: :lb)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: gwen).update(posted_at: Date.new(2018, 1, 9))

# ==============================================================================
# Marguerita
# 50 reps for time
# Burpee/Push-up/Jumping-Jack/Sit-up/Handstand
marguerita = Workout.find_or_create_by(name: 'Marguerita') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(rounds: 50, position: 1)
  segment.exercises.build(movement: burpee, position: 1, reps: 1)
  segment.exercises.build(movement: push_up, position: 2, reps: 1)
  segment.exercises.build(movement: jumping_jack, position: 3, reps: 1)
  segment.exercises.build(movement: sit_up, position: 4, reps: 1)
  segment.exercises.build(movement: handstand, position: 5, reps: 1)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: marguerita).update(posted_at: Date.new(2018, 1, 8))

# ==============================================================================
# Candy
# 5 rounds for time
# 20 pull-ups
# 40 push-ups
# 60 squats
candy = Workout.find_or_create_by(name: 'Candy') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(rounds: 5, position: 1)
  segment.exercises.build(movement: pull_up, position: 1, reps: 20)
  segment.exercises.build(movement: push_up, position: 2, reps: 40)
  segment.exercises.build(movement: air_squat, position: 3, reps: 60)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: candy).update(posted_at: Date.new(2018, 1, 7))

# ==============================================================================
# Maggie
# 5 rounds for time
# 20 handstand push-ups
# 40 pull-ups
# 60 one-legged squats, alternating legs
maggie = Workout.find_or_create_by(name: 'Maggie') do |workout|
  workout.score_type = :time
  segment = workout.segments.build(rounds: 5, position: 1)
  segment.exercises.build(movement: handstand_push_up, position: 1, reps: 20)
  segment.exercises.build(movement: pull_up, position: 2, reps: 40)
  segment.exercises.build(movement: single_leg_squat_pistol, position: 3, reps: 60)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: maggie).update(posted_at: Date.new(2018, 1, 6))

## =============================================================================
# Hope
# 3 rounds for max reps
# Burpees
# 75-lb. power snatches
# Box jumps, 24-inch box
# 75-pound thrusters
# Chest-to-bar pull-ups
# "Hope" has the same format as Fight Gone Bad. In this workout you move from
# each of five stations after a minute. This is a five-minute round after which
# a one-minute break is allowed before repeating. The clock does not reset or
# stop between exercises. On the call of "rotate," the athlete(s) must move to
# the next station immediately for a good score. One point is given for each rep.
hope = Workout.find_or_create_by(name: 'Hope') do |workout|
  workout.score_type = :rep
  workout.notes = '"Hope" has the same format as Fight Gone Bad. In this ' \
                  'workout you move from each of five stations after a minute. ' \
                  'This is a five-minute round from which a one-minute break is ' \
                  'allowed before repeating. The clock does not reset or stop ' \
                  'between exercises. On call of "rotate," the athlete/s must ' \
                  'move to next station immediately for good score. One point ' \
                  'is given for each rep.'
  segment = workout.segments.build(rounds: 3, time_seconds: 1080, position: 1)
  segment.exercises.build(movement: burpee, position: 1, reps: 0)
  segment.exercises.build(movement: snatch, position: 2, reps: 0, female_load: 55, male_load: 75, load_unit: :lb)
  segment.exercises.build(movement: box_jump, position: 3, reps: 0, female_distance: 20, male_distance: 24, distance_unit: :inch)
  segment.exercises.build(movement: thruster, position: 4, reps: 0, female_load: 55, male_load: 75, load_unit: :lb)
  segment.exercises.build(movement: chest_to_bar_pull_up, position: 5, reps: 0)
  segment.exercises.build(movement: rest, position: 6, reps: 1, duration_seconds: 60)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: hope).update(posted_at: Date.new(2018, 1, 5))
