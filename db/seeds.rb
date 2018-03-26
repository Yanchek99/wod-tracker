# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
hspu = Movement.find_or_create_by(name: 'Handstand Push-up', measurement: Movement.measurements[:weight])
lpu = Movement.find_or_create_by(name: 'L Pull-ups', measurement: Movement.measurements[:weight])
t2b = Movement.find_or_create_by(name: 'Toes To Bar')
db_hcj = Movement.find_or_create_by(name: 'Dumbbell Hang Clean and Jerk', measurement: Movement.measurements[:weight])
row = Movement.find_or_create_by(name: 'Row')
run = Movement.find_or_create_by(name: 'Run', measurement: Movement.measurements[:distance])
du = Movement.find_or_create_by(name: 'Double Under')
pu = Movement.find_or_create_by(name: 'Push-up')
pc = Movement.find_or_create_by(name: 'Power Clean', measurement: Movement.measurements[:weight])
ps = Movement.find_or_create_by(name: 'Power Snatch', measurement: Movement.measurements[:weight])
fs = Movement.find_or_create_by(name: 'Front Squat', measurement: Movement.measurements[:weight])
ohs = Movement.find_or_create_by(name: 'Overhead Squat', measurement: Movement.measurements[:weight])
ghdsu = Movement.find_or_create_by(name: 'GHD Sit-up')
he = Movement.find_or_create_by(name: 'Hip Extensions')
hw = Movement.find_or_create_by(name: 'Handstand Walk')
bj = Movement.find_or_create_by(name: 'Box Jump', measurement: 'height')
wall_ball = Movement.find_or_create_by(name: 'Wall-ball Shots', measurement: Movement.measurements[:weight])
rest = Movement.find_or_create_by(name: 'Rest', measurement: Movement.measurements[:time])

# Sunday 180225
# 10 rounds for time of:
# 1 power snatch
# 3 overhead squats
# Men: 185 lb.
# Women: 125 lb.
sunday = Workout.find_or_create_by(name: 'Sunday 180225') do |workout|
  workout.rounds = 10
  workout.exercises.build(movement: ps, reps: 1, male_rx: 185, female_rx: 125)
  workout.exercises.build(movement: ohs, reps: 3, male_rx: 185, female_rx: 125)
end

Log.create(workout: sunday, time: 3, weight: 185)

# Saturday 180224
# 21-18-15-12-9-6-3 reps of:
# Handstand push-ups
# L pull-ups
saturday = Workout.find_or_create_by(name: 'Kelly') do |workout|
  workout.interval = '21-18-15-12-9-6-3'
  workout.exercises.build(movement: hspu, reps: 1)
  workout.exercises.build(movement: lpu, reps: 1)
end

Log.create(workout: saturday, time: 20, weight: 0)

# Friday 180223
# Workout 18.1
# Complete as many rounds as possible in 20 minutes of:
# 8 toes-to-bars
# 10 dumbbell hang clean and jerks
# 14 / 12-cal. row
friday = Workout.find_or_create_by(name: 'Workout 18.1') do |workout|
  workout.time = 20
  workout.exercises.build(movement: t2b, reps: 8)
  workout.exercises.build(movement: db_hcj, reps: 10, male_rx: 50, female_rx: 30)
  workout.exercises.build(movement: row, reps: 1,  measurement: 'calories', male_rx: 14, female_rx: 12)
end

Log.create(workout: friday, time: 20, rounds: 7.8, weight: 0)

# Wednesday 180221
# 8 rounds for time of:
# Run 400 meters
# Rest 90 seconds
wednesday = Workout.find_or_create_by(name: 'Wednesday 180221') do |workout|
  workout.rounds = 8
  workout.exercises.build(movement: run, reps: 1, measurement: 'meter', measurement_value: 400)
  workout.exercises.build(movement: rest, reps: 1, measurement: 'second', measurement_value: 90)
end

Log.create(workout: wednesday, time: 10, rounds: 8, weight: 0)

# Tuesday 180220
# Havana
# Complete as many rounds as possible in 25 minutes of:
# 150 double-unders
# 50 push-ups
# 15 power cleans
tuesday_180220 = Workout.find_or_create_by(name: 'Tuesday 180220') do |workout|
  workout.time = 25
  workout.exercises.build(movement: du, reps: 150)
  workout.exercises.build(movement: pu, reps: 50)
  workout.exercises.build(movement: pc, reps: 15, male_rx: 185, female_rx: 125)
end

Log.create(workout: tuesday_180220, time: 25, rounds: 8, weight: 150)

# Monday 180219
# 4 rounds for time of:
# 30 GHD sit-ups
# 30 hip extensions
# 100-ft. handstand walk
monday_180219 = Workout.find_or_create_by(name: 'Monday 180219') do |workout|
  workout.rounds = 4
  workout.exercises.build(movement: ghdsu, reps: 30)
  workout.exercises.build(movement: he, reps: 30)
  workout.exercises.build(movement: hw, reps: 1, measurement: 'feet', measurement_value: 100)
end

Log.create(workout: monday_180219, time: 10, rounds: 4, weight: 0)

# Saturday 180217
# Five 3-minute rounds of:
# 10 front squats
# 10 box jumps
# Row for max calories
# Rest 3 minutes between rounds.
saturday_180217 = Workout.find_or_create_by(name: 'Saturday 180217') do |workout|
  workout.rounds = 5
  workout.time = 3
  workout.exercises.build(movement: fs, reps: 10, male_rx: 185, female_rx: 125)
  workout.exercises.build(movement: bj, reps: 10, male_rx: 36, female_rx: 30)
  workout.exercises.build(movement: row, reps: 1, measurement: 'calories', measurement_value: 'max')
  workout.exercises.build(movement: rest, reps: 1, measurement: 'minute', measurement_value: 3)
end

Log.create(workout: saturday_180217, time: 10, rounds: 5, weight: 185)
