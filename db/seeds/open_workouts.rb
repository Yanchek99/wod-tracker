# CrossFit Open Workouts (2011-2026)
#
# Source: https://games.crossfit.com/workouts/open
# Loads are the standard Men's Rx'd / Women's Rx'd prescriptions (female_load / male_load).
# Single "max reps" movements use reps: 0 (the app's max-reps sentinel). Open-ended ascending
# ladders (11.6-style) set workout.ladder_step (the per-round increment); each exercise's reps are
# its round-1 start, an exercise that increments on a slower cadence sets ladder_step_every, and a
# movement that stays constant sets ladder_exempt: true. The Open frequently repeats an earlier
# workout; rather than seed a duplicate, each repeat is left as a code comment pointing at the
# original (e.g. "# 12.5 is a repeat of 11.6").

# ==============================================================================
# 2011
# ==============================================================================

# 11.1
# AMRAP 10 minutes
# 30 double-unders
# 15 power snatches (75 / 55 lb)
Workout.find_or_create_by(name: 'Open 11.1') do |workout|
  workout.time = 10
  workout.score_type = :rep
  workout.exercises.build(movement: double_under, position: 1, reps: 30)
  workout.exercises.build(movement: power_snatch, position: 2, reps: 15, female_load: 55, male_load: 75, load_unit: :lb)
end

# 11.2
# AMRAP 15 minutes
# 9 deadlifts (155 / 100 lb)
# 12 hand-release push-ups
# 15 box jumps (24 / 20 in)
Workout.find_or_create_by(name: 'Open 11.2') do |workout|
  workout.time = 15
  workout.score_type = :rep
  workout.exercises.build(movement: deadlift, position: 1, reps: 9, female_load: 100, male_load: 155, load_unit: :lb)
  workout.exercises.build(movement: push_up, position: 2, reps: 12, notes: 'Hand-release push-ups.')
  workout.exercises.build(movement: box_jump, position: 3, reps: 15, female_distance: 20, male_distance: 24, distance_unit: :inch)
end

# 11.3
# AMRAP 5 minutes
# Clean and jerk (165 / 110 lb)
Workout.find_or_create_by(name: 'Open 11.3') do |workout|
  workout.time = 5
  workout.score_type = :rep
  workout.notes = 'Max clean and jerks in 5 minutes. Post total reps.'
  workout.exercises.build(movement: clean_and_jerk, position: 1, reps: 0, female_load: 110, male_load: 165, load_unit: :lb)
end

# 11.4
# AMRAP 10 minutes
# 60 bar-facing burpees
# 30 overhead squats (120 / 90 lb)
# 10 muscle-ups
Workout.find_or_create_by(name: 'Open 11.4') do |workout|
  workout.time = 10
  workout.score_type = :rep
  workout.exercises.build(movement: over_the_bar_burpee, position: 1, reps: 60,
                          notes: 'Bar-facing burpees, jumping over the barbell.')
  workout.exercises.build(movement: overhead_squat, position: 2, reps: 30, female_load: 90, male_load: 120, load_unit: :lb)
  workout.exercises.build(movement: muscle_up, position: 3, reps: 10)
end

# 11.5
# AMRAP 20 minutes
# 5 power cleans (145 / 100 lb)
# 10 toes-to-bar
# 15 wall-ball shots (20 lb to 10 ft / 14 lb to 9 ft)
Workout.find_or_create_by(name: 'Open 11.5') do |workout|
  workout.time = 20
  workout.score_type = :rep
  workout.exercises.build(movement: power_clean, position: 1, reps: 5, female_load: 100, male_load: 145, load_unit: :lb)
  workout.exercises.build(movement: toes_to_bar, position: 2, reps: 10)
  workout.exercises.build(movement: wall_ball_shot, position: 3, reps: 15,
                          female_load: 14, male_load: 20, load_unit: :lb,
                          female_distance: 9, male_distance: 10, distance_unit: :foot)
end

# 11.6
# AMRAP 7 minutes, ascending ladder (3, 6, 9, ... add 3 reps each round)
# Thrusters (100 / 65 lb)
# Chest-to-bar pull-ups
Workout.find_or_create_by(name: 'Open 11.6') do |workout|
  workout.time = 7
  workout.score_type = :rep
  workout.ladder_step = 3
  workout.notes = 'Post total reps.'
  workout.exercises.build(movement: thruster, position: 1, reps: 3, female_load: 65, male_load: 100, load_unit: :lb)
  workout.exercises.build(movement: chest_to_bar_pull_up, position: 2, reps: 3)
end

# ==============================================================================
# 2012
# ==============================================================================

# 12.1
# AMRAP 7 minutes
# Burpees (jump and touch a target 6 in above standing reach)
Workout.find_or_create_by(name: 'Open 12.1') do |workout|
  workout.time = 7
  workout.score_type = :rep
  workout.notes = 'Each burpee: chest and thighs to the floor, then jump and touch a target ' \
                  '6 inches above standing reach. Post total burpees.'
  workout.exercises.build(movement: burpee, position: 1, reps: 0)
end

# 12.2
# AMRAP 10 minutes, ascending-load snatch ladder
# 30 snatches (75 / 45 lb)
# 30 snatches (135 / 75 lb)
# 30 snatches (165 / 100 lb)
# Max snatches (210 / 120 lb)
Workout.find_or_create_by(name: 'Open 12.2') do |workout|
  workout.time = 10
  workout.score_type = :rep
  workout.notes = 'Proceed through the loads in order, completing all 30 reps at a load before advancing. ' \
                  'After 90 reps, perform max reps at the heaviest load. Post total reps.'
  workout.exercises.build(movement: snatch, position: 1, reps: 30, female_load: 45, male_load: 75, load_unit: :lb)
  workout.exercises.build(movement: snatch, position: 2, reps: 30, female_load: 75, male_load: 135, load_unit: :lb)
  workout.exercises.build(movement: snatch, position: 3, reps: 30, female_load: 100, male_load: 165, load_unit: :lb)
  workout.exercises.build(movement: snatch, position: 4, reps: 0, female_load: 120, male_load: 210, load_unit: :lb)
end

# 12.3
# AMRAP 18 minutes
# 15 box jumps (24 / 20 in)
# 12 push presses (115 / 75 lb)
# 9 toes-to-bar
Workout.find_or_create_by(name: 'Open 12.3') do |workout|
  workout.time = 18
  workout.score_type = :rep
  workout.exercises.build(movement: box_jump, position: 1, reps: 15, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: push_press, position: 2, reps: 12, female_load: 75, male_load: 115, load_unit: :lb)
  workout.exercises.build(movement: toes_to_bar, position: 3, reps: 9)
end

# 12.4
# AMRAP 12 minutes
# 150 wall-ball shots (20 lb to 10 ft / 14 lb to 9 ft)
# 90 double-unders
# 30 muscle-ups
Workout.find_or_create_by(name: 'Open 12.4') do |workout|
  workout.time = 12
  workout.score_type = :rep
  workout.exercises.build(movement: wall_ball_shot, position: 1, reps: 150,
                          female_load: 14, male_load: 20, load_unit: :lb,
                          female_distance: 9, male_distance: 10, distance_unit: :foot)
  workout.exercises.build(movement: double_under, position: 2, reps: 90)
  workout.exercises.build(movement: muscle_up, position: 3, reps: 30)
end

# 12.5 is a repeat of 11.6

# ==============================================================================
# 2013
# ==============================================================================

# 13.1
# AMRAP 17 minutes
# 40 burpees
# 30 snatches (75 / 45 lb)
# 30 burpees
# 30 snatches (135 / 75 lb)
# 20 burpees
# 30 snatches (165 / 100 lb)
# 10 burpees
# Max snatches (210 / 120 lb)
Workout.find_or_create_by(name: 'Open 13.1') do |workout|
  workout.time = 17
  workout.score_type = :rep
  workout.notes = 'Work through the chipper in order; the final snatches are max reps at the heaviest load. ' \
                  'Post total reps.'
  workout.exercises.build(movement: burpee, position: 1, reps: 40)
  workout.exercises.build(movement: snatch, position: 2, reps: 30, female_load: 45, male_load: 75, load_unit: :lb)
  workout.exercises.build(movement: burpee, position: 3, reps: 30)
  workout.exercises.build(movement: snatch, position: 4, reps: 30, female_load: 75, male_load: 135, load_unit: :lb)
  workout.exercises.build(movement: burpee, position: 5, reps: 20)
  workout.exercises.build(movement: snatch, position: 6, reps: 30, female_load: 100, male_load: 165, load_unit: :lb)
  workout.exercises.build(movement: burpee, position: 7, reps: 10)
  workout.exercises.build(movement: snatch, position: 8, reps: 0, female_load: 120, male_load: 210, load_unit: :lb)
end

# 13.2
# AMRAP 10 minutes
# 5 shoulder-to-overhead (115 / 75 lb)
# 10 deadlifts (115 / 75 lb)
# 15 box jumps (24 / 20 in)
Workout.find_or_create_by(name: 'Open 13.2') do |workout|
  workout.time = 10
  workout.score_type = :rep
  workout.exercises.build(movement: shoulder_to_overhead, position: 1, reps: 5, female_load: 75, male_load: 115, load_unit: :lb)
  workout.exercises.build(movement: deadlift, position: 2, reps: 10, female_load: 75, male_load: 115, load_unit: :lb)
  workout.exercises.build(movement: box_jump, position: 3, reps: 15, female_distance: 20, male_distance: 24, distance_unit: :inch)
end

# 13.3 is a repeat of 12.4

# 13.4
# AMRAP 7 minutes, ascending ladder (3, 6, 9, ... add 3 reps each round)
# Clean and jerk (135 / 95 lb)
# Toes-to-bar
Workout.find_or_create_by(name: 'Open 13.4') do |workout|
  workout.time = 7
  workout.score_type = :rep
  workout.ladder_step = 3
  workout.notes = 'Post total reps.'
  workout.exercises.build(movement: clean_and_jerk, position: 1, reps: 3, female_load: 95, male_load: 135, load_unit: :lb)
  workout.exercises.build(movement: toes_to_bar, position: 2, reps: 3)
end

# 13.5
# For max reps; 4-minute base that extends 4 minutes for every 3 rounds completed
# 15 thrusters (100 / 65 lb)
# 15 chest-to-bar pull-ups
Workout.find_or_create_by(name: 'Open 13.5') do |workout|
  workout.time = 4
  workout.score_type = :rep
  workout.notes = 'Begin with a 4-minute window. Completing 3 rounds (90 reps) extends the cap to 8 minutes; ' \
                  '6 rounds to 12 minutes; 9 rounds to 16 minutes; and so on. Post total reps.'
  workout.exercises.build(movement: thruster, position: 1, reps: 15, female_load: 65, male_load: 100, load_unit: :lb)
  workout.exercises.build(movement: chest_to_bar_pull_up, position: 2, reps: 15)
end

# ==============================================================================
# 2014
# ==============================================================================

# 14.1 is a repeat of 11.1

# 14.2
# Every 3 minutes for as long as possible
# 2 rounds of: 10 overhead squats (95 / 65 lb) + 10 chest-to-bar pull-ups,
# adding 2 reps to each movement every 3-minute window (10, 12, 14, ...)
Workout.find_or_create_by(name: 'Open 14.2') do |workout|
  workout.score_type = :rep
  workout.ladder_step = 2
  workout.notes = 'Every 3 minutes for as long as possible: complete 2 rounds of the couplet. The reps ' \
                  'hold for both rounds of a window, then grow by 2 in the next window (10, 12, 14, ...). ' \
                  'Continue until you fail to finish both rounds inside a window. Post total reps.'
  workout.exercises.build(movement: overhead_squat, position: 1, reps: 10, ladder_step_every: 2,
                          female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: chest_to_bar_pull_up, position: 2, reps: 10, ladder_step_every: 2)
end

# 14.3
# AMRAP 8 minutes, ascending-load deadlift ladder with box jumps
# 10 deadlifts (135 / 95 lb), 15 box jumps (24 / 20 in)
# 15 deadlifts (185 / 135 lb), 15 box jumps
# 20 deadlifts (225 / 155 lb), 15 box jumps
# 25 deadlifts (275 / 185 lb), 15 box jumps
# 30 deadlifts (315 / 205 lb), 15 box jumps
# 35 deadlifts (365 / 225 lb), 15 box jumps
Workout.find_or_create_by(name: 'Open 14.3') do |workout|
  workout.time = 8
  workout.score_type = :rep
  workout.notes = 'Deadlift load increases each round; box jumps stay at 15 reps. Post total reps.'
  workout.exercises.build(movement: deadlift, position: 1, reps: 10, female_load: 95, male_load: 135, load_unit: :lb)
  workout.exercises.build(movement: box_jump, position: 2, reps: 15, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: deadlift, position: 3, reps: 15, female_load: 135, male_load: 185, load_unit: :lb)
  workout.exercises.build(movement: box_jump, position: 4, reps: 15, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: deadlift, position: 5, reps: 20, female_load: 155, male_load: 225, load_unit: :lb)
  workout.exercises.build(movement: box_jump, position: 6, reps: 15, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: deadlift, position: 7, reps: 25, female_load: 185, male_load: 275, load_unit: :lb)
  workout.exercises.build(movement: box_jump, position: 8, reps: 15, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: deadlift, position: 9, reps: 30, female_load: 205, male_load: 315, load_unit: :lb)
  workout.exercises.build(movement: box_jump, position: 10, reps: 15, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: deadlift, position: 11, reps: 35, female_load: 225, male_load: 365, load_unit: :lb)
  workout.exercises.build(movement: box_jump, position: 12, reps: 15, female_distance: 20, male_distance: 24, distance_unit: :inch)
end

# 14.4
# AMRAP 14 minutes (chipper)
# 60-calorie row
# 50 toes-to-bar
# 40 wall-ball shots (20 lb to 10 ft / 14 lb to 9 ft)
# 30 cleans (135 / 95 lb)
# 20 muscle-ups
Workout.find_or_create_by(name: 'Open 14.4') do |workout|
  workout.time = 14
  workout.score_type = :rep
  workout.exercises.build(movement: row, position: 1, reps: 1, calories: 60)
  workout.exercises.build(movement: toes_to_bar, position: 2, reps: 50)
  workout.exercises.build(movement: wall_ball_shot, position: 3, reps: 40,
                          female_load: 14, male_load: 20, load_unit: :lb,
                          female_distance: 9, male_distance: 10, distance_unit: :foot)
  workout.exercises.build(movement: clean, position: 4, reps: 30, female_load: 95, male_load: 135, load_unit: :lb)
  workout.exercises.build(movement: muscle_up, position: 5, reps: 20)
end

# 14.5
# For time (no time cap): 21-18-15-12-9-6-3 reps of
# Thrusters (95 / 65 lb)
# Bar-facing burpees
Workout.find_or_create_by(name: 'Open 14.5') do |workout|
  workout.interval = '21-18-15-12-9-6-3'
  workout.score_type = :time
  workout.notes = 'Bar-facing burpees jump over the barbell. No time cap. Post total time.'
  workout.exercises.build(movement: thruster, position: 1, reps: 1, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: over_the_bar_burpee, position: 2, reps: 1)
end

# ==============================================================================
# 2015
# ==============================================================================

# 15.1
# AMRAP 9 minutes
# 15 toes-to-bar
# 10 deadlifts (115 / 75 lb)
# 5 snatches (115 / 75 lb)
Workout.find_or_create_by(name: 'Open 15.1') do |workout|
  workout.time = 9
  workout.score_type = :rep
  workout.exercises.build(movement: toes_to_bar, position: 1, reps: 15)
  workout.exercises.build(movement: deadlift, position: 2, reps: 10, female_load: 75, male_load: 115, load_unit: :lb)
  workout.exercises.build(movement: snatch, position: 3, reps: 5, female_load: 75, male_load: 115, load_unit: :lb)
end

# 15.1a
# 6-minute time cap to establish a 1-rep-max clean and jerk (performed immediately after 15.1)
Workout.find_or_create_by(name: 'Open 15.1a') do |workout|
  workout.score_type = :weight
  workout.time_cap_seconds = 360
  workout.notes = 'Performed immediately following 15.1. Establish a 1-rep-max clean and jerk within ' \
                  '6 minutes. Post heaviest successful load.'
  workout.exercises.build(movement: clean_and_jerk, position: 1, reps: 1)
end

# 15.2 is a repeat of 14.2

# 15.3
# AMRAP 14 minutes
# 7 muscle-ups
# 50 wall-ball shots (20 lb to 10 ft / 14 lb to 9 ft)
# 100 double-unders
Workout.find_or_create_by(name: 'Open 15.3') do |workout|
  workout.time = 14
  workout.score_type = :rep
  workout.exercises.build(movement: muscle_up, position: 1, reps: 7)
  workout.exercises.build(movement: wall_ball_shot, position: 2, reps: 50,
                          female_load: 14, male_load: 20, load_unit: :lb,
                          female_distance: 9, male_distance: 10, distance_unit: :foot)
  workout.exercises.build(movement: double_under, position: 3, reps: 100)
end

# 15.4
# AMRAP 8 minutes, ascending ladder
# Handstand push-ups (3, 6, 9, 12, ... add 3 each round)
# Cleans (185 / 125 lb) (add 3 reps every three rounds: 3, 3, 3, 6, 6, 6, 9, ...)
Workout.find_or_create_by(name: 'Open 15.4') do |workout|
  workout.time = 8
  workout.score_type = :rep
  workout.ladder_step = 3
  workout.notes = 'Handstand push-ups increase by 3 each round (3, 6, 9, ...); cleans increase by 3 every ' \
                  'three rounds (3, 3, 3, 6, 6, 6, 9, ...). Post total reps.'
  workout.exercises.build(movement: handstand_push_up, position: 1, reps: 3)
  workout.exercises.build(movement: clean, position: 2, reps: 3, ladder_step_every: 3,
                          female_load: 125, male_load: 185, load_unit: :lb)
end

# 15.5
# For time: 27-21-15-9 reps of
# Row (calories)
# Thrusters (95 / 65 lb)
Workout.find_or_create_by(name: 'Open 15.5') do |workout|
  workout.interval = '27-21-15-9'
  workout.score_type = :time
  workout.notes = 'The row is scored in calories. Post total time.'
  workout.exercises.build(movement: row, position: 1, reps: 1, notes: 'Calories.')
  workout.exercises.build(movement: thruster, position: 2, reps: 1, female_load: 65, male_load: 95, load_unit: :lb)
end

# ==============================================================================
# 2016
# ==============================================================================

# 16.1
# AMRAP 20 minutes
# 25-ft overhead walking lunge (95 / 65 lb)
# 8 burpees
# 25-ft overhead walking lunge (95 / 65 lb)
# 8 chest-to-bar pull-ups
Workout.find_or_create_by(name: 'Open 16.1') do |workout|
  workout.time = 20
  workout.score_type = :rep
  workout.notes = 'The barbell is held overhead during the walking lunges. Post total reps.'
  workout.exercises.build(movement: walking_lunge, position: 1, reps: 1, distance: 25, distance_unit: :foot,
                          female_load: 65, male_load: 95, load_unit: :lb, notes: 'Barbell held overhead.')
  workout.exercises.build(movement: burpee, position: 2, reps: 8)
  workout.exercises.build(movement: walking_lunge, position: 3, reps: 1, distance: 25, distance_unit: :foot,
                          female_load: 65, male_load: 95, load_unit: :lb, notes: 'Barbell held overhead.')
  workout.exercises.build(movement: chest_to_bar_pull_up, position: 4, reps: 8)
end

# 16.2
# Ascending ladder in 4-minute windows, 20-minute cap
# Each window: 25 toes-to-bar, 50 double-unders, then the round's squat cleans
# Cleans by round: 15 (135/85), 13 (185/115), 11 (225/145), 9 (275/175), 7 (315/205) lb
Workout.find_or_create_by(name: 'Open 16.2') do |workout|
  workout.time = 20
  workout.score_type = :rep
  workout.notes = 'Ascending ladder in 4-minute windows (20-minute cap). Each window repeats 25 toes-to-bar and ' \
                  '50 double-unders, then the round\'s squat cleans; advance only if you finish within the window. ' \
                  'Squat cleans by round: 15 @ 135/85, 13 @ 185/115, 11 @ 225/145, 9 @ 275/175, 7 @ 315/205 lb. ' \
                  'Post total reps.'
  workout.exercises.build(movement: toes_to_bar, position: 1, reps: 25)
  workout.exercises.build(movement: double_under, position: 2, reps: 50)
  workout.exercises.build(movement: clean, position: 3, reps: 15, female_load: 85, male_load: 135, load_unit: :lb)
  workout.exercises.build(movement: clean, position: 4, reps: 13, female_load: 115, male_load: 185, load_unit: :lb)
  workout.exercises.build(movement: clean, position: 5, reps: 11, female_load: 145, male_load: 225, load_unit: :lb)
  workout.exercises.build(movement: clean, position: 6, reps: 9, female_load: 175, male_load: 275, load_unit: :lb)
  workout.exercises.build(movement: clean, position: 7, reps: 7, female_load: 205, male_load: 315, load_unit: :lb)
end

# 16.3
# AMRAP 7 minutes
# 10 power snatches (75 / 55 lb)
# 3 bar muscle-ups
Workout.find_or_create_by(name: 'Open 16.3') do |workout|
  workout.time = 7
  workout.score_type = :rep
  workout.exercises.build(movement: power_snatch, position: 1, reps: 10, female_load: 55, male_load: 75, load_unit: :lb)
  workout.exercises.build(movement: bar_muscle_up, position: 2, reps: 3)
end

# 16.4
# AMRAP 13 minutes
# 55 deadlifts (225 / 155 lb)
# 55 wall-ball shots (20 lb to 10 ft / 14 lb to 9 ft)
# 55-calorie row
# 55 handstand push-ups
Workout.find_or_create_by(name: 'Open 16.4') do |workout|
  workout.time = 13
  workout.score_type = :rep
  workout.exercises.build(movement: deadlift, position: 1, reps: 55, female_load: 155, male_load: 225, load_unit: :lb)
  workout.exercises.build(movement: wall_ball_shot, position: 2, reps: 55,
                          female_load: 14, male_load: 20, load_unit: :lb,
                          female_distance: 9, male_distance: 10, distance_unit: :foot)
  workout.exercises.build(movement: row, position: 3, reps: 1, calories: 55)
  workout.exercises.build(movement: handstand_push_up, position: 4, reps: 55)
end

# 16.5 is a repeat of 14.5

# ==============================================================================
# 2017
# ==============================================================================

# 17.1
# For time (20-minute cap)
# 10 / 20 / 30 / 40 / 50 dumbbell snatches, with 15 burpee box jump-overs between each set
# Dumbbell 50 / 35 lb, box 24 / 20 in
Workout.find_or_create_by(name: 'Open 17.1') do |workout|
  workout.score_type = :time
  workout.time_cap_seconds = 1200
  workout.notes = 'Single-arm dumbbell snatches, alternating arms. Sets of 10, 20, 30, 40, 50 dumbbell snatches, ' \
                  'each followed by 15 burpee box jump-overs. 20-minute cap. Post total time (or reps if capped).'
  workout.exercises.build(movement: dumbbell_power_snatch, position: 1, reps: 10, female_load: 35, male_load: 50, load_unit: :lb)
  workout.exercises.build(movement: burpee_box_jump_over, position: 2, reps: 15, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: dumbbell_power_snatch, position: 3, reps: 20, female_load: 35, male_load: 50, load_unit: :lb)
  workout.exercises.build(movement: burpee_box_jump_over, position: 4, reps: 15, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: dumbbell_power_snatch, position: 5, reps: 30, female_load: 35, male_load: 50, load_unit: :lb)
  workout.exercises.build(movement: burpee_box_jump_over, position: 6, reps: 15, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: dumbbell_power_snatch, position: 7, reps: 40, female_load: 35, male_load: 50, load_unit: :lb)
  workout.exercises.build(movement: burpee_box_jump_over, position: 8, reps: 15, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: dumbbell_power_snatch, position: 9, reps: 50, female_load: 35, male_load: 50, load_unit: :lb)
  workout.exercises.build(movement: burpee_box_jump_over, position: 10, reps: 15, female_distance: 20, male_distance: 24, distance_unit: :inch)
end

# 17.2
# AMRAP 12 minutes (two dumbbells, 50 / 35 lb)
# Alternating every 2 rounds between toes-to-bar and bar muscle-ups
Workout.find_or_create_by(name: 'Open 17.2') do |workout|
  workout.time = 12
  workout.score_type = :rep
  workout.notes = 'Complete 2 rounds of: 50-ft dumbbell walking lunge, 16 toes-to-bar, 8 dumbbell power cleans. ' \
                  'Then 2 rounds of: 50-ft dumbbell walking lunge, 16 bar muscle-ups, 8 dumbbell power cleans. ' \
                  'Continue alternating toes-to-bar and bar muscle-ups every 2 rounds. Two 50/35-lb dumbbells ' \
                  'held at the shoulders. Post total reps.'
  workout.exercises.build(movement: dumbbell_front_rack_lunge, position: 1, reps: 1, distance: 50, distance_unit: :foot,
                          female_load: 35, male_load: 50, load_unit: :lb, implement_count: 2,
                          notes: 'Two dumbbells at the shoulders.')
  workout.exercises.build(movement: toes_to_bar, position: 2, reps: 16)
  workout.exercises.build(movement: dumbbell_power_clean, position: 3, reps: 8,
                          female_load: 35, male_load: 50, load_unit: :lb, implement_count: 2)
  workout.exercises.build(movement: bar_muscle_up, position: 4, reps: 16)
end

# 17.3
# Sectioned ascending ladder (first section 8 minutes, +4 minutes per completed section, 24-minute cap)
# Each section is 3 rounds of: N chest-to-bar pull-ups + M squat snatches
# Pull-ups 6,7,8,9,10,11 / snatches 6,5,4,3,2,1
# Snatch loads: 95/65, 135/95, 185/135, 225/155, 245/175, 265/185 lb
Workout.find_or_create_by(name: 'Open 17.3') do |workout|
  workout.score_type = :rep
  workout.time_cap_seconds = 1440
  workout.notes = 'Complete 3 rounds of each section before advancing; reps and load shown are per round. ' \
                  'The first section has an 8-minute window; each completed section adds 4 minutes, up to a ' \
                  '24-minute cap. Post total reps.'
  workout.exercises.build(movement: chest_to_bar_pull_up, position: 1, reps: 6)
  workout.exercises.build(movement: snatch, position: 2, reps: 6, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: chest_to_bar_pull_up, position: 3, reps: 7)
  workout.exercises.build(movement: snatch, position: 4, reps: 5, female_load: 95, male_load: 135, load_unit: :lb)
  workout.exercises.build(movement: chest_to_bar_pull_up, position: 5, reps: 8)
  workout.exercises.build(movement: snatch, position: 6, reps: 4, female_load: 135, male_load: 185, load_unit: :lb)
  workout.exercises.build(movement: chest_to_bar_pull_up, position: 7, reps: 9)
  workout.exercises.build(movement: snatch, position: 8, reps: 3, female_load: 155, male_load: 225, load_unit: :lb)
  workout.exercises.build(movement: chest_to_bar_pull_up, position: 9, reps: 10)
  workout.exercises.build(movement: snatch, position: 10, reps: 2, female_load: 175, male_load: 245, load_unit: :lb)
  workout.exercises.build(movement: chest_to_bar_pull_up, position: 11, reps: 11)
  workout.exercises.build(movement: snatch, position: 12, reps: 1, female_load: 185, male_load: 265, load_unit: :lb)
end

# 17.4 is a repeat of 16.4

# 17.5
# 10 rounds for time (40-minute cap)
# 9 thrusters (95 / 65 lb)
# 35 double-unders
Workout.find_or_create_by(name: 'Open 17.5') do |workout|
  workout.rounds = 10
  workout.score_type = :time
  workout.time_cap_seconds = 2400
  workout.notes = '10 rounds for time, 40-minute cap. Post total time.'
  workout.exercises.build(movement: thruster, position: 1, reps: 9, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: double_under, position: 2, reps: 35)
end

# ==============================================================================
# 2018
# ==============================================================================

# 18.1
# AMRAP 20 minutes
# 8 toes-to-bar
# 10 dumbbell hang clean and jerks (50 / 35 lb, 5 per arm)
# 14 / 12-calorie row
Workout.find_or_create_by(name: 'Open 18.1') do |workout|
  workout.time = 20
  workout.score_type = :rep
  workout.exercises.build(movement: toes_to_bar, position: 1, reps: 8)
  workout.exercises.build(movement: dumbbell_hang_clean_and_jerk, position: 2, reps: 10,
                          female_load: 35, male_load: 50, load_unit: :lb, notes: '5 reps per arm.')
  workout.exercises.build(movement: row, position: 3, reps: 1, female_calories: 12, male_calories: 14)
end

# 18.2
# For time (12-minute cap, shared with 18.2a): 1-2-3-4-5-6-7-8-9-10 reps of
# Dumbbell squats (50 / 35 lb)
# Bar-facing burpees
Workout.find_or_create_by(name: 'Open 18.2') do |workout|
  workout.interval = '1-2-3-4-5-6-7-8-9-10'
  workout.score_type = :time
  workout.time_cap_seconds = 720
  workout.notes = 'Dumbbell squats hold two dumbbells at the shoulders. Bar-facing burpees jump over the barbell. ' \
                  '12-minute cap shared with 18.2a. Post total time.'
  workout.exercises.build(movement: dumbbell_front_squat, position: 1, reps: 1,
                          female_load: 35, male_load: 50, load_unit: :lb, implement_count: 2)
  workout.exercises.build(movement: over_the_bar_burpee, position: 2, reps: 1)
end

# 18.2a
# 1-rep-max clean (begins after finishing 18.2, within the same 12-minute cap)
Workout.find_or_create_by(name: 'Open 18.2a') do |workout|
  workout.score_type = :weight
  workout.time_cap_seconds = 720
  workout.notes = 'Performed immediately after completing 18.2, in the time remaining within the 12-minute cap. ' \
                  'Establish a 1-rep-max clean. Post heaviest successful load.'
  workout.exercises.build(movement: clean, position: 1, reps: 1)
end

# 18.3
# 2 rounds for time (14-minute cap)
# 100 double-unders
# 20 overhead squats (115 / 80 lb)
# 100 double-unders
# 12 ring muscle-ups
# 100 double-unders
# 20 dumbbell snatches (50 / 35 lb)
# 100 double-unders
# 12 bar muscle-ups
Workout.find_or_create_by(name: 'Open 18.3') do |workout|
  workout.rounds = 2
  workout.score_type = :time
  workout.time_cap_seconds = 840
  workout.notes = '2 rounds for time, 14-minute cap. Post total time.'
  workout.exercises.build(movement: double_under, position: 1, reps: 100)
  workout.exercises.build(movement: overhead_squat, position: 2, reps: 20, female_load: 80, male_load: 115, load_unit: :lb)
  workout.exercises.build(movement: double_under, position: 3, reps: 100)
  workout.exercises.build(movement: ring_muscle_up, position: 4, reps: 12)
  workout.exercises.build(movement: double_under, position: 5, reps: 100)
  workout.exercises.build(movement: dumbbell_power_snatch, position: 6, reps: 20, female_load: 35, male_load: 50, load_unit: :lb)
  workout.exercises.build(movement: double_under, position: 7, reps: 100)
  workout.exercises.build(movement: bar_muscle_up, position: 8, reps: 12)
end

# 18.4
# For time (9-minute cap)
# 21-15-9 reps of deadlifts (225 / 155 lb) and handstand push-ups
# Then 21-15-9 reps of deadlifts (315 / 205 lb), each set followed by a 50-ft handstand walk
Workout.find_or_create_by(name: 'Open 18.4') do |workout|
  workout.score_type = :time
  workout.time_cap_seconds = 540
  workout.notes = 'For time, 9-minute cap. 21-15-9 of deadlift + handstand push-up at the lighter load, ' \
                  'then 21-15-9 of the heavier deadlift with a 50-ft handstand walk after each set. Post total time.'
  workout.exercises.build(movement: deadlift, position: 1, reps: 21, female_load: 155, male_load: 225, load_unit: :lb)
  workout.exercises.build(movement: handstand_push_up, position: 2, reps: 21)
  workout.exercises.build(movement: deadlift, position: 3, reps: 15, female_load: 155, male_load: 225, load_unit: :lb)
  workout.exercises.build(movement: handstand_push_up, position: 4, reps: 15)
  workout.exercises.build(movement: deadlift, position: 5, reps: 9, female_load: 155, male_load: 225, load_unit: :lb)
  workout.exercises.build(movement: handstand_push_up, position: 6, reps: 9)
  workout.exercises.build(movement: deadlift, position: 7, reps: 21, female_load: 205, male_load: 315, load_unit: :lb)
  workout.exercises.build(movement: handstand_walk, position: 8, reps: 1, distance: 50, distance_unit: :foot)
  workout.exercises.build(movement: deadlift, position: 9, reps: 15, female_load: 205, male_load: 315, load_unit: :lb)
  workout.exercises.build(movement: handstand_walk, position: 10, reps: 1, distance: 50, distance_unit: :foot)
  workout.exercises.build(movement: deadlift, position: 11, reps: 9, female_load: 205, male_load: 315, load_unit: :lb)
  workout.exercises.build(movement: handstand_walk, position: 12, reps: 1, distance: 50, distance_unit: :foot)
end

# 18.5 is a repeat of 11.6 (also run as 12.5)

# ==============================================================================
# 2019
# ==============================================================================

# 19.1
# AMRAP 15 minutes
# 19 wall-ball shots (20 lb to 10 ft / 14 lb to 9 ft)
# 19-calorie row
Workout.find_or_create_by(name: 'Open 19.1') do |workout|
  workout.time = 15
  workout.score_type = :rep
  workout.exercises.build(movement: wall_ball_shot, position: 1, reps: 19,
                          female_load: 14, male_load: 20, load_unit: :lb,
                          female_distance: 9, male_distance: 10, distance_unit: :foot)
  workout.exercises.build(movement: row, position: 2, reps: 1, calories: 19)
end

# 19.2 is a repeat of 16.2

# 19.3
# For time (10-minute cap)
# 200-ft dumbbell overhead walking lunge (50 / 35 lb)
# 50 dumbbell box step-ups (50 / 35 lb, 24 / 20 in box)
# 50 strict handstand push-ups
# 200-ft handstand walk
Workout.find_or_create_by(name: 'Open 19.3') do |workout|
  workout.score_type = :time
  workout.time_cap_seconds = 600
  workout.notes = 'For time, 10-minute cap. The dumbbell is held overhead for the lunge. Post total time.'
  workout.exercises.build(movement: dumbbell_overhead_walking_lunge, position: 1, reps: 1, distance: 200, distance_unit: :foot,
                          female_load: 35, male_load: 50, load_unit: :lb)
  workout.exercises.build(movement: dumbbell_box_step_up, position: 2, reps: 50,
                          female_load: 35, male_load: 50, load_unit: :lb,
                          female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: strict_handstand_push_up, position: 3, reps: 50)
  workout.exercises.build(movement: handstand_walk, position: 4, reps: 1, distance: 200, distance_unit: :foot)
end

# 19.4
# For total time (12-minute cap)
# 3 rounds of: 10 snatches (95 / 65 lb) + 12 bar-facing burpees
# Rest 3 minutes
# 3 rounds of: 10 bar muscle-ups + 12 bar-facing burpees
Workout.find_or_create_by(name: 'Open 19.4') do |workout|
  workout.score_type = :time
  workout.time_cap_seconds = 720
  workout.notes = 'For total time, 12-minute cap. Complete the first 3-round block, rest exactly 3 minutes, ' \
                  'then complete the second 3-round block. Athletes who do not finish the first block by the ' \
                  '9-minute mark score 66 reps. Bar-facing burpees jump over the barbell. Post total time.'
  first_block = workout.segments.build(rounds: 3, position: 1)
  workout.exercises.build(movement: snatch, segment: first_block, position: 1, reps: 10,
                          female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: over_the_bar_burpee, segment: first_block, position: 2, reps: 12)
  workout.exercises.build(movement: rest, position: 2, reps: 1, duration_seconds: 180)
  second_block = workout.segments.build(rounds: 3, position: 3)
  workout.exercises.build(movement: bar_muscle_up, segment: second_block, position: 1, reps: 10)
  workout.exercises.build(movement: over_the_bar_burpee, segment: second_block, position: 2, reps: 12)
end

# 19.5
# For time (20-minute cap): 33-27-21-15-9 reps of
# Thrusters (95 / 65 lb)
# Chest-to-bar pull-ups
Workout.find_or_create_by(name: 'Open 19.5') do |workout|
  workout.interval = '33-27-21-15-9'
  workout.score_type = :time
  workout.time_cap_seconds = 1200
  workout.notes = 'For time, 20-minute cap. Post total time.'
  workout.exercises.build(movement: thruster, position: 1, reps: 1, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: chest_to_bar_pull_up, position: 2, reps: 1)
end

# ==============================================================================
# 2020
# ==============================================================================

# 20.1
# 10 rounds for time (15-minute cap)
# 8 ground-to-overhead (95 / 65 lb)
# 10 bar-facing burpees
Workout.find_or_create_by(name: 'Open 20.1') do |workout|
  workout.rounds = 10
  workout.score_type = :time
  workout.time_cap_seconds = 900
  workout.notes = '10 rounds for time, 15-minute cap. Ground-to-overhead by any method. Bar-facing burpees ' \
                  'jump over the barbell. Post total time.'
  workout.exercises.build(movement: ground_to_overhead, position: 1, reps: 8, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: over_the_bar_burpee, position: 2, reps: 10)
end

# 20.2
# AMRAP 20 minutes
# 4 dumbbell thrusters (50 / 35 lb)
# 6 toes-to-bar
# 24 double-unders
Workout.find_or_create_by(name: 'Open 20.2') do |workout|
  workout.time = 20
  workout.score_type = :rep
  workout.exercises.build(movement: dumbbell_thruster, position: 1, reps: 4,
                          female_load: 35, male_load: 50, load_unit: :lb, implement_count: 2)
  workout.exercises.build(movement: toes_to_bar, position: 2, reps: 6)
  workout.exercises.build(movement: double_under, position: 3, reps: 24)
end

# 20.3 is a repeat of 18.4

# 20.4
# For time (20-minute cap)
# 30 box jumps (24 / 20 in), 15 clean and jerks (95 / 65 lb)
# 30 box jumps, 15 clean and jerks (135 / 85 lb)
# 30 box jumps, 10 clean and jerks (185 / 115 lb)
# 30 single-leg squats, 10 clean and jerks (225 / 145 lb)
# 30 single-leg squats, 5 clean and jerks (275 / 175 lb)
# 30 single-leg squats, 5 clean and jerks (315 / 205 lb)
Workout.find_or_create_by(name: 'Open 20.4') do |workout|
  workout.score_type = :time
  workout.time_cap_seconds = 1200
  workout.notes = 'For time, 20-minute cap. Post total time.'
  workout.exercises.build(movement: box_jump, position: 1, reps: 30, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: clean_and_jerk, position: 2, reps: 15, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: box_jump, position: 3, reps: 30, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: clean_and_jerk, position: 4, reps: 15, female_load: 85, male_load: 135, load_unit: :lb)
  workout.exercises.build(movement: box_jump, position: 5, reps: 30, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: clean_and_jerk, position: 6, reps: 10, female_load: 115, male_load: 185, load_unit: :lb)
  workout.exercises.build(movement: single_leg_squat_pistol, position: 7, reps: 30)
  workout.exercises.build(movement: clean_and_jerk, position: 8, reps: 10, female_load: 145, male_load: 225, load_unit: :lb)
  workout.exercises.build(movement: single_leg_squat_pistol, position: 9, reps: 30)
  workout.exercises.build(movement: clean_and_jerk, position: 10, reps: 5, female_load: 175, male_load: 275, load_unit: :lb)
  workout.exercises.build(movement: single_leg_squat_pistol, position: 11, reps: 30)
  workout.exercises.build(movement: clean_and_jerk, position: 12, reps: 5, female_load: 205, male_load: 315, load_unit: :lb)
end

# 20.5
# For time (20-minute cap), partitioned any way
# 40 muscle-ups
# 80-calorie row
# 120 wall-ball shots (20 lb to 10 ft / 14 lb to 9 ft)
Workout.find_or_create_by(name: 'Open 20.5') do |workout|
  workout.score_type = :time
  workout.time_cap_seconds = 1200
  workout.notes = 'For time, 20-minute cap. The reps may be partitioned and performed in any order. Post total time.'
  workout.exercises.build(movement: ring_muscle_up, position: 1, reps: 40)
  workout.exercises.build(movement: row, position: 2, reps: 1, calories: 80)
  workout.exercises.build(movement: wall_ball_shot, position: 3, reps: 120,
                          female_load: 14, male_load: 20, load_unit: :lb,
                          female_distance: 9, male_distance: 10, distance_unit: :foot)
end

# ==============================================================================
# 2021
# ==============================================================================

# 21.1
# For time (15-minute cap)
# 1 wall walk, 10 double-unders
# 3 wall walks, 30 double-unders
# 6 wall walks, 60 double-unders
# 9 wall walks, 90 double-unders
# 15 wall walks, 150 double-unders
# 21 wall walks, 210 double-unders
Workout.find_or_create_by(name: 'Open 21.1') do |workout|
  workout.score_type = :time
  workout.time_cap_seconds = 900
  workout.notes = 'For time, 15-minute cap. Post total time.'
  workout.exercises.build(movement: wall_walk, position: 1, reps: 1)
  workout.exercises.build(movement: double_under, position: 2, reps: 10)
  workout.exercises.build(movement: wall_walk, position: 3, reps: 3)
  workout.exercises.build(movement: double_under, position: 4, reps: 30)
  workout.exercises.build(movement: wall_walk, position: 5, reps: 6)
  workout.exercises.build(movement: double_under, position: 6, reps: 60)
  workout.exercises.build(movement: wall_walk, position: 7, reps: 9)
  workout.exercises.build(movement: double_under, position: 8, reps: 90)
  workout.exercises.build(movement: wall_walk, position: 9, reps: 15)
  workout.exercises.build(movement: double_under, position: 10, reps: 150)
  workout.exercises.build(movement: wall_walk, position: 11, reps: 21)
  workout.exercises.build(movement: double_under, position: 12, reps: 210)
end

# 21.2 is a repeat of 17.1

# 21.3
# For total time (15-minute cap); 21.4 begins immediately after
# 3 blocks of: 15 front squats (95 / 65 lb), 30 gymnastics reps, 15 thrusters (95 / 65 lb)
# Gymnastics by block: toes-to-bar, chest-to-bar pull-ups, bar muscle-ups; rest 1 minute between blocks
Workout.find_or_create_by(name: 'Open 21.3') do |workout|
  workout.score_type = :time
  workout.time_cap_seconds = 900
  workout.notes = 'For total time, 15-minute cap. Rest 1 minute between blocks. 21.4 begins immediately upon ' \
                  'finishing or reaching the cap. Post total time.'
  workout.exercises.build(movement: front_squat, position: 1, reps: 15, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: toes_to_bar, position: 2, reps: 30)
  workout.exercises.build(movement: thruster, position: 3, reps: 15, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: rest, position: 4, reps: 1, duration_seconds: 60)
  workout.exercises.build(movement: front_squat, position: 5, reps: 15, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: chest_to_bar_pull_up, position: 6, reps: 30)
  workout.exercises.build(movement: thruster, position: 7, reps: 15, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: rest, position: 8, reps: 1, duration_seconds: 60)
  workout.exercises.build(movement: front_squat, position: 9, reps: 15, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: bar_muscle_up, position: 10, reps: 30)
  workout.exercises.build(movement: thruster, position: 11, reps: 15, female_load: 65, male_load: 95, load_unit: :lb)
end

# 21.4
# 1-rep-max complex for load (7-minute cap, begins immediately after 21.3)
# 1 deadlift + 1 clean + 1 hang clean + 1 jerk
Workout.find_or_create_by(name: 'Open 21.4') do |workout|
  workout.score_type = :weight
  workout.time_cap_seconds = 420
  workout.notes = 'Begins immediately after 21.3. Complete the complex for max load: 1 deadlift, 1 clean, ' \
                  '1 hang clean, 1 jerk. Post the heaviest successful complex.'
  workout.exercises.build(movement: deadlift, position: 1, reps: 1)
  workout.exercises.build(movement: clean, position: 2, reps: 1)
  workout.exercises.build(movement: hang_clean, position: 3, reps: 1)
  workout.exercises.build(movement: jerk, position: 4, reps: 1)
end

# ==============================================================================
# 2022
# ==============================================================================

# 22.1
# AMRAP 15 minutes
# 3 wall walks
# 12 dumbbell snatches (50 / 35 lb)
# 15 box jump-overs (24 / 20 in)
Workout.find_or_create_by(name: 'Open 22.1') do |workout|
  workout.time = 15
  workout.score_type = :rep
  workout.exercises.build(movement: wall_walk, position: 1, reps: 3)
  workout.exercises.build(movement: dumbbell_power_snatch, position: 2, reps: 12, female_load: 35, male_load: 50, load_unit: :lb)
  workout.exercises.build(movement: box_jump_over, position: 3, reps: 15, female_distance: 20, male_distance: 24, distance_unit: :inch)
end

# 22.2
# For time (10-minute cap): 1-2-3-4-5-6-7-8-9-10-9-8-7-6-5-4-3-2-1 reps of
# Deadlifts (225 / 155 lb)
# Bar-facing burpees
Workout.find_or_create_by(name: 'Open 22.2') do |workout|
  workout.interval = '1-2-3-4-5-6-7-8-9-10-9-8-7-6-5-4-3-2-1'
  workout.score_type = :time
  workout.time_cap_seconds = 600
  workout.notes = 'Pyramid rep scheme up to 10 and back down to 1. Bar-facing burpees jump over the barbell. ' \
                  '10-minute cap. Post total time.'
  workout.exercises.build(movement: deadlift, position: 1, reps: 1, female_load: 155, male_load: 225, load_unit: :lb)
  workout.exercises.build(movement: over_the_bar_burpee, position: 2, reps: 1)
end

# 22.3
# For time (12-minute cap)
# 21 pull-ups, 42 double-unders, 21 thrusters (95 / 65 lb)
# 18 chest-to-bar pull-ups, 36 double-unders, 18 thrusters (115 / 75 lb)
# 15 bar muscle-ups, 30 double-unders, 15 thrusters (135 / 85 lb)
Workout.find_or_create_by(name: 'Open 22.3') do |workout|
  workout.score_type = :time
  workout.time_cap_seconds = 720
  workout.notes = 'For time, 12-minute cap. Post total time.'
  workout.exercises.build(movement: pull_up, position: 1, reps: 21)
  workout.exercises.build(movement: double_under, position: 2, reps: 42)
  workout.exercises.build(movement: thruster, position: 3, reps: 21, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: chest_to_bar_pull_up, position: 4, reps: 18)
  workout.exercises.build(movement: double_under, position: 5, reps: 36)
  workout.exercises.build(movement: thruster, position: 6, reps: 18, female_load: 75, male_load: 115, load_unit: :lb)
  workout.exercises.build(movement: bar_muscle_up, position: 7, reps: 15)
  workout.exercises.build(movement: double_under, position: 8, reps: 30)
  workout.exercises.build(movement: thruster, position: 9, reps: 15, female_load: 85, male_load: 135, load_unit: :lb)
end

# ==============================================================================
# 2023
# ==============================================================================

# 23.1 is a repeat of 14.4

# 23.2A
# AMRAP 15 minutes
# 5 burpee pull-ups, 10 shuttle runs; add 5 burpee pull-ups after each round
Workout.find_or_create_by(name: 'Open 23.2A') do |workout|
  workout.time = 15
  workout.score_type = :rep
  workout.ladder_step = 5
  workout.notes = 'The burpee pull-ups ascend (5, 10, 15, ...); the shuttle runs stay at 10 each round. ' \
                  'One shuttle-run rep is 25 ft out and 25 ft back. Post total reps.'
  workout.exercises.build(movement: burpee_pull_up, position: 1, reps: 5)
  workout.exercises.build(movement: shuttle_run, position: 2, reps: 10, ladder_exempt: true,
                          notes: '1 rep = 25 ft out and 25 ft back.')
end

# 23.2B
# 5-minute cap to establish a 1-rep-max thruster from the floor (immediately after 23.2A)
Workout.find_or_create_by(name: 'Open 23.2B') do |workout|
  workout.score_type = :weight
  workout.time_cap_seconds = 300
  workout.notes = 'Performed immediately after 23.2A. Establish a 1-rep-max thruster taken from the floor ' \
                  'within 5 minutes. Post heaviest successful load.'
  workout.exercises.build(movement: thruster, position: 1, reps: 1)
end

# 23.3
# Progressive ladder (6-minute cap; +3 minutes after each completed part, to 9- then 12-minute cap)
# Part 1: 5 wall walks, 50 double-unders, 15 snatches (95/65); 5 wall walks, 50 double-unders, 12 snatches (135/95)
# Part 2: 20 strict handstand push-ups, 50 double-unders, 9 snatches (185/125)
# Part 3: 20 strict handstand push-ups, 50 double-unders, 6 snatches (225/155)
Workout.find_or_create_by(name: 'Open 23.3') do |workout|
  workout.score_type = :rep
  workout.time_cap_seconds = 720
  workout.notes = 'Begin with a 6-minute cap; completing a part adds 3 minutes (to a 9-minute, then 12-minute ' \
                  'cap). Post total reps.'
  workout.exercises.build(movement: wall_walk, position: 1, reps: 5)
  workout.exercises.build(movement: double_under, position: 2, reps: 50)
  workout.exercises.build(movement: snatch, position: 3, reps: 15, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: wall_walk, position: 4, reps: 5)
  workout.exercises.build(movement: double_under, position: 5, reps: 50)
  workout.exercises.build(movement: snatch, position: 6, reps: 12, female_load: 95, male_load: 135, load_unit: :lb)
  workout.exercises.build(movement: strict_handstand_push_up, position: 7, reps: 20)
  workout.exercises.build(movement: double_under, position: 8, reps: 50)
  workout.exercises.build(movement: snatch, position: 9, reps: 9, female_load: 125, male_load: 185, load_unit: :lb)
  workout.exercises.build(movement: strict_handstand_push_up, position: 10, reps: 20)
  workout.exercises.build(movement: double_under, position: 11, reps: 50)
  workout.exercises.build(movement: snatch, position: 12, reps: 6, female_load: 155, male_load: 225, load_unit: :lb)
end

# ==============================================================================
# 2024
# ==============================================================================

# 24.1
# For time (15-minute cap): 21-15-9 reps, each round performed once per arm
# Dumbbell snatches (arm 1), lateral burpees over the dumbbell, dumbbell snatches (arm 2), lateral burpees
# Dumbbell 50 / 35 lb
Workout.find_or_create_by(name: 'Open 24.1') do |workout|
  workout.score_type = :time
  workout.time_cap_seconds = 900
  workout.notes = 'For time, 15-minute cap. Each round (21, then 15, then 9) is: that many dumbbell snatches ' \
                  'on arm 1, that many lateral burpees over the dumbbell, that many dumbbell snatches on arm 2, ' \
                  'that many lateral burpees over the dumbbell. Post total time.'
  workout.exercises.build(movement: dumbbell_power_snatch, position: 1, reps: 21, female_load: 35, male_load: 50, load_unit: :lb, notes: 'Arm 1.')
  workout.exercises.build(movement: lateral_burpee_over_dumbbell, position: 2, reps: 21)
  workout.exercises.build(movement: dumbbell_power_snatch, position: 3, reps: 21, female_load: 35, male_load: 50, load_unit: :lb, notes: 'Arm 2.')
  workout.exercises.build(movement: lateral_burpee_over_dumbbell, position: 4, reps: 21)
  workout.exercises.build(movement: dumbbell_power_snatch, position: 5, reps: 15, female_load: 35, male_load: 50, load_unit: :lb, notes: 'Arm 1.')
  workout.exercises.build(movement: lateral_burpee_over_dumbbell, position: 6, reps: 15)
  workout.exercises.build(movement: dumbbell_power_snatch, position: 7, reps: 15, female_load: 35, male_load: 50, load_unit: :lb, notes: 'Arm 2.')
  workout.exercises.build(movement: lateral_burpee_over_dumbbell, position: 8, reps: 15)
  workout.exercises.build(movement: dumbbell_power_snatch, position: 9, reps: 9, female_load: 35, male_load: 50, load_unit: :lb, notes: 'Arm 1.')
  workout.exercises.build(movement: lateral_burpee_over_dumbbell, position: 10, reps: 9)
  workout.exercises.build(movement: dumbbell_power_snatch, position: 11, reps: 9, female_load: 35, male_load: 50, load_unit: :lb, notes: 'Arm 2.')
  workout.exercises.build(movement: lateral_burpee_over_dumbbell, position: 12, reps: 9)
end

# 24.2
# AMRAP 20 minutes
# 300-meter row
# 10 deadlifts (185 / 125 lb)
# 50 double-unders
Workout.find_or_create_by(name: 'Open 24.2') do |workout|
  workout.time = 20
  workout.score_type = :rep
  workout.exercises.build(movement: row, position: 1, reps: 1, distance: 300, distance_unit: :meter)
  workout.exercises.build(movement: deadlift, position: 2, reps: 10, female_load: 125, male_load: 185, load_unit: :lb)
  workout.exercises.build(movement: double_under, position: 3, reps: 50)
end

# 24.3
# For time (15-minute cap)
# Part 1: 5 rounds of 10 thrusters (95 / 65 lb) + 10 chest-to-bar pull-ups
# Rest 1 minute
# Part 2: 5 rounds of 7 thrusters (135 / 95 lb) + 7 bar muscle-ups
Workout.find_or_create_by(name: 'Open 24.3') do |workout|
  workout.score_type = :time
  workout.time_cap_seconds = 900
  workout.notes = 'For time, 15-minute cap. Rest 1 minute between parts. Post total time.'
  part1 = workout.segments.build(rounds: 5, position: 1)
  workout.exercises.build(movement: thruster, segment: part1, position: 1, reps: 10, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: chest_to_bar_pull_up, segment: part1, position: 2, reps: 10)
  workout.exercises.build(movement: rest, position: 2, reps: 1, duration_seconds: 60)
  part2 = workout.segments.build(rounds: 5, position: 3)
  workout.exercises.build(movement: thruster, segment: part2, position: 1, reps: 7, female_load: 95, male_load: 135, load_unit: :lb)
  workout.exercises.build(movement: bar_muscle_up, segment: part2, position: 2, reps: 7)
end

# ==============================================================================
# 2025
# ==============================================================================

# 25.1
# AMRAP 15 minutes (ascending)
# 3 lateral burpees over the dumbbell
# 3 dumbbell hang clean-to-overheads (50 / 35 lb)
# 30-ft walking lunge (15 ft out, 15 ft back)
# Add 3 reps to the burpees and hang clean-to-overheads each round; the lunge stays at 30 ft
Workout.find_or_create_by(name: 'Open 25.1') do |workout|
  workout.time = 15
  workout.score_type = :rep
  workout.ladder_step = 3
  workout.notes = 'The lateral burpees over the dumbbell and dumbbell hang clean-to-overheads ascend ' \
                  '(3, 6, 9, ...); the 30-ft walking lunge (15 ft out, 15 ft back) stays constant each round. ' \
                  'A single 50/35-lb dumbbell. Post total reps.'
  workout.exercises.build(movement: lateral_burpee_over_dumbbell, position: 1, reps: 3)
  workout.exercises.build(movement: dumbbell_hang_clean_and_jerk, position: 2, reps: 3,
                          female_load: 35, male_load: 50, load_unit: :lb, notes: 'Hang clean-to-overhead.')
  workout.exercises.build(movement: walking_lunge, position: 3, reps: 1, distance: 30, distance_unit: :foot,
                          ladder_exempt: true)
end

# 25.2 is a repeat of 22.3

# 25.3
# For time (20-minute cap)
# 5 wall walks, 50-calorie row
# 5 wall walks, 25 deadlifts (225 / 155 lb)
# 5 wall walks, 25 cleans (135 / 85 lb)
# 5 wall walks, 25 snatches (95 / 65 lb)
# 5 wall walks, 50-calorie row
Workout.find_or_create_by(name: 'Open 25.3') do |workout|
  workout.score_type = :time
  workout.time_cap_seconds = 1200
  workout.notes = 'For time, 20-minute cap. Cleans and snatches are taken from the floor (no hang reps). ' \
                  'Post total time.'
  workout.exercises.build(movement: wall_walk, position: 1, reps: 5)
  workout.exercises.build(movement: row, position: 2, reps: 1, calories: 50)
  workout.exercises.build(movement: wall_walk, position: 3, reps: 5)
  workout.exercises.build(movement: deadlift, position: 4, reps: 25, female_load: 155, male_load: 225, load_unit: :lb)
  workout.exercises.build(movement: wall_walk, position: 5, reps: 5)
  workout.exercises.build(movement: clean, position: 6, reps: 25, female_load: 85, male_load: 135, load_unit: :lb)
  workout.exercises.build(movement: wall_walk, position: 7, reps: 5)
  workout.exercises.build(movement: snatch, position: 8, reps: 25, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: wall_walk, position: 9, reps: 5)
  workout.exercises.build(movement: row, position: 10, reps: 1, calories: 50)
end

# ==============================================================================
# 2026
# ==============================================================================

# 26.1
# For time (12-minute cap)
# 20 wall-ball shots, 18 box jump-overs
# 30 wall-ball shots, 18 box jump-overs
# 40 wall-ball shots, 18 medicine-ball box step-overs
# 66 wall-ball shots, 18 medicine-ball box step-overs
# 40 wall-ball shots, 18 box jump-overs
# 30 wall-ball shots, 18 box jump-overs
# 20 wall-ball shots
# Medicine ball 20 / 14 lb to 10 / 9 ft target, box 24 / 20 in
Workout.find_or_create_by(name: 'Open 26.1') do |workout|
  workout.score_type = :time
  workout.time_cap_seconds = 720
  workout.notes = 'For time, 12-minute cap. Post total time.'
  workout.exercises.build(movement: wall_ball_shot, position: 1, reps: 20,
                          female_load: 14, male_load: 20, load_unit: :lb,
                          female_distance: 9, male_distance: 10, distance_unit: :foot)
  workout.exercises.build(movement: box_jump_over, position: 2, reps: 18, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: wall_ball_shot, position: 3, reps: 30,
                          female_load: 14, male_load: 20, load_unit: :lb,
                          female_distance: 9, male_distance: 10, distance_unit: :foot)
  workout.exercises.build(movement: box_jump_over, position: 4, reps: 18, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: wall_ball_shot, position: 5, reps: 40,
                          female_load: 14, male_load: 20, load_unit: :lb,
                          female_distance: 9, male_distance: 10, distance_unit: :foot)
  workout.exercises.build(movement: medicine_ball_box_step_over, position: 6, reps: 18,
                          female_load: 14, male_load: 20, load_unit: :lb,
                          female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: wall_ball_shot, position: 7, reps: 66,
                          female_load: 14, male_load: 20, load_unit: :lb,
                          female_distance: 9, male_distance: 10, distance_unit: :foot)
  workout.exercises.build(movement: medicine_ball_box_step_over, position: 8, reps: 18,
                          female_load: 14, male_load: 20, load_unit: :lb,
                          female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: wall_ball_shot, position: 9, reps: 40,
                          female_load: 14, male_load: 20, load_unit: :lb,
                          female_distance: 9, male_distance: 10, distance_unit: :foot)
  workout.exercises.build(movement: box_jump_over, position: 10, reps: 18, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: wall_ball_shot, position: 11, reps: 30,
                          female_load: 14, male_load: 20, load_unit: :lb,
                          female_distance: 9, male_distance: 10, distance_unit: :foot)
  workout.exercises.build(movement: box_jump_over, position: 12, reps: 18, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: wall_ball_shot, position: 13, reps: 20,
                          female_load: 14, male_load: 20, load_unit: :lb,
                          female_distance: 9, male_distance: 10, distance_unit: :foot)
end

# 26.2
# For time (15-minute cap)
# 80-ft dumbbell overhead walking lunge, 20 alternating dumbbell snatches, 20 pull-ups
# 80-ft dumbbell overhead walking lunge, 20 alternating dumbbell snatches, 20 chest-to-bar pull-ups
# 80-ft dumbbell overhead walking lunge, 20 alternating dumbbell snatches, 20 muscle-ups
# Dumbbell 50 / 35 lb
Workout.find_or_create_by(name: 'Open 26.2') do |workout|
  workout.score_type = :time
  workout.time_cap_seconds = 900
  workout.notes = 'For time, 15-minute cap. The dumbbell is held overhead for the lunge; the snatches ' \
                  'alternate arms. Post total time.'
  workout.exercises.build(movement: dumbbell_overhead_walking_lunge, position: 1, reps: 1, distance: 80, distance_unit: :foot,
                          female_load: 35, male_load: 50, load_unit: :lb)
  workout.exercises.build(movement: dumbbell_power_snatch, position: 2, reps: 20, female_load: 35, male_load: 50, load_unit: :lb)
  workout.exercises.build(movement: pull_up, position: 3, reps: 20)
  workout.exercises.build(movement: dumbbell_overhead_walking_lunge, position: 4, reps: 1, distance: 80, distance_unit: :foot,
                          female_load: 35, male_load: 50, load_unit: :lb)
  workout.exercises.build(movement: dumbbell_power_snatch, position: 5, reps: 20, female_load: 35, male_load: 50, load_unit: :lb)
  workout.exercises.build(movement: chest_to_bar_pull_up, position: 6, reps: 20)
  workout.exercises.build(movement: dumbbell_overhead_walking_lunge, position: 7, reps: 1, distance: 80, distance_unit: :foot,
                          female_load: 35, male_load: 50, load_unit: :lb)
  workout.exercises.build(movement: dumbbell_power_snatch, position: 8, reps: 20, female_load: 35, male_load: 50, load_unit: :lb)
  workout.exercises.build(movement: muscle_up, position: 9, reps: 20)
end

# 26.3
# For time (16-minute cap)
# 2 rounds of: 12 burpees over the bar, 12 cleans, 12 burpees over the bar, 12 thrusters (95 / 65 lb)
# 2 rounds of the same at 115 / 75 lb
# 2 rounds of the same at 135 / 85 lb
Workout.find_or_create_by(name: 'Open 26.3') do |workout|
  workout.score_type = :time
  workout.time_cap_seconds = 960
  workout.notes = 'For time, 16-minute cap. Burpees over the bar jump over the barbell. Post total time.'
  block1 = workout.segments.build(rounds: 2, position: 1)
  workout.exercises.build(movement: over_the_bar_burpee, segment: block1, position: 1, reps: 12)
  workout.exercises.build(movement: clean, segment: block1, position: 2, reps: 12, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: over_the_bar_burpee, segment: block1, position: 3, reps: 12)
  workout.exercises.build(movement: thruster, segment: block1, position: 4, reps: 12, female_load: 65, male_load: 95, load_unit: :lb)
  block2 = workout.segments.build(rounds: 2, position: 2)
  workout.exercises.build(movement: over_the_bar_burpee, segment: block2, position: 1, reps: 12)
  workout.exercises.build(movement: clean, segment: block2, position: 2, reps: 12, female_load: 75, male_load: 115, load_unit: :lb)
  workout.exercises.build(movement: over_the_bar_burpee, segment: block2, position: 3, reps: 12)
  workout.exercises.build(movement: thruster, segment: block2, position: 4, reps: 12, female_load: 75, male_load: 115, load_unit: :lb)
  block3 = workout.segments.build(rounds: 2, position: 3)
  workout.exercises.build(movement: over_the_bar_burpee, segment: block3, position: 1, reps: 12)
  workout.exercises.build(movement: clean, segment: block3, position: 2, reps: 12, female_load: 85, male_load: 135, load_unit: :lb)
  workout.exercises.build(movement: over_the_bar_burpee, segment: block3, position: 3, reps: 12)
  workout.exercises.build(movement: thruster, segment: block3, position: 4, reps: 12, female_load: 85, male_load: 135, load_unit: :lb)
end
