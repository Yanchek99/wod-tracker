# Hero WODS

# ==============================================================================
# JT
# 21-15-9 reps for time
# Handstand push-ups
# Ring dips
# Push-ups
Workout.find_or_create_by(name: 'JT') do |workout|
  workout.interval = '21-15-9'
  workout.score_type = :time
  workout.exercises.build(movement: handstand_push_up, position: 1, reps: 1)
  workout.exercises.build(movement: ring_dip, position: 2, reps: 1)
  workout.exercises.build(movement: push_up, position: 3, reps: 1)
end

# ==============================================================================
# Michael
# 3 rounds for time
# Run 800 meters
# 50 back extensions
# 50 sit-ups
Workout.find_or_create_by(name: 'Michael') do |workout|
  workout.rounds = 3
  workout.score_type = :time
  workout.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  workout.exercises.build(movement: back_extensions, position: 2, reps: 50)
  workout.exercises.build(movement: sit_up, position: 3, reps: 50)
end

# ==============================================================================
# Murph
# For time
# Run 1 mile
# 100 pull-ups
# 200 push-ups
# 300 squats
# Run 1 mile
Workout.find_or_create_by(name: 'Murph') do |workout|
  workout.rounds = 1
  workout.score_type = :time
  workout.exercises.build(movement: run, position: 1, reps: 1, distance: 1600, distance_unit: :meter)
  workout.exercises.build(movement: pull_up, position: 2, reps: 100)
  workout.exercises.build(movement: push_up, position: 3, reps: 200)
  workout.exercises.build(movement: air_squat, position: 4, reps: 300)
  workout.exercises.build(movement: run, position: 5, reps: 1, distance: 1600, distance_unit: :meter)
end

# ==============================================================================
# Daniel
# For time
# 50 pull-ups
# 400-meter run
# 95-lb. thrusters, 21 reps
# 800-meter run
# 95-lb. thrusters, 21 reps
# 400-meter run
# 50 pull-ups
Workout.find_or_create_by(name: 'Daniel') do |workout|
  workout.rounds = 1
  workout.score_type = :time
  workout.exercises.build(movement: pull_up, position: 1, reps: 50)
  workout.exercises.build(movement: run, position: 2, reps: 1, distance: 400, distance_unit: :meter)
  workout.exercises.build(movement: thruster, position: 3, reps: 21, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: run, position: 4, reps: 1, distance: 800, distance_unit: :meter)
  workout.exercises.build(movement: thruster, position: 5, reps: 21, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: run, position: 6, reps: 1, distance: 400, distance_unit: :meter)
  workout.exercises.build(movement: pull_up, position: 7, reps: 50)
end

# ==============================================================================
# Josh
# For time
# 95-lb. overhead squats, 21 reps
# 42 pull-ups
# 95-lb. overhead squats, 15 reps
# 30 pull-ups
# 95-lb. overhead squats, 9 reps
# 18 pull-ups
Workout.find_or_create_by(name: 'Josh') do |workout|
  workout.rounds = 1
  workout.score_type = :time
  workout.exercises.build(movement: overhead_squat, position: 1, reps: 21, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: pull_up, position: 2, reps: 42)
  workout.exercises.build(movement: overhead_squat, position: 3, reps: 15, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: pull_up, position: 4, reps: 30)
  workout.exercises.build(movement: overhead_squat, position: 5, reps: 9, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: pull_up, position: 6, reps: 18)
end

# ==============================================================================
# Jason
# For time
# 100 squats
# 5 muscle-ups
# 75 squats
# 10 muscle-ups
# 50 squats
# 15 muscle-ups
# 25 squats
# 20 muscle-ups
Workout.find_or_create_by(name: 'Jason') do |workout|
  workout.rounds = 1
  workout.score_type = :time
  workout.exercises.build(movement: air_squat, position: 1, reps: 100)
  workout.exercises.build(movement: muscle_up, position: 2, reps: 5)
  workout.exercises.build(movement: air_squat, position: 3, reps: 75)
  workout.exercises.build(movement: muscle_up, position: 4, reps: 10)
  workout.exercises.build(movement: air_squat, position: 5, reps: 50)
  workout.exercises.build(movement: muscle_up, position: 6, reps: 15)
  workout.exercises.build(movement: air_squat, position: 7, reps: 25)
  workout.exercises.build(movement: muscle_up, position: 8, reps: 20)
end
