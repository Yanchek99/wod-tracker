# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.find_or_create_by(email: 'matt.yanchek@gmail.com') do |u|
  u.password = 'cr0ssF!t'
end


hspu = Movement.find_or_create_by(name: 'Handstand Push-up', measurement: Movement.measurements[:weight])
lpu = Movement.find_or_create_by(name: 'L Pull-up', measurement: Movement.measurements[:weight])
t2b = Movement.find_or_create_by(name: 'Toes To Bar')
db_hcj = Movement.find_or_create_by(name: 'Dumbbell Hang Clean and Jerk', measurement: Movement.measurements[:weight])
row = Movement.find_or_create_by(name: 'Row')
run = Movement.find_or_create_by(name: 'Run', measurement: Movement.measurements[:distance])
du = Movement.find_or_create_by(name: 'Double Under')
pu = Movement.find_or_create_by(name: 'Push-up')
tj = Movement.find_or_create_by(name: 'Tempo Jerk', measurement: Movement.measurements[:weight])
pc = Movement.find_or_create_by(name: 'Power Clean', measurement: Movement.measurements[:weight])
ps = Movement.find_or_create_by(name: 'Power Snatch', measurement: Movement.measurements[:weight])
hpc = Movement.find_or_create_by(name: 'Hang Power Snatch', measurement: Movement.measurements[:weight])
fs = Movement.find_or_create_by(name: 'Front Squat', measurement: Movement.measurements[:weight])
bs = Movement.find_or_create_by(name: 'Back Squat', measurement: Movement.measurements[:weight])
ohs = Movement.find_or_create_by(name: 'Overhead Squat', measurement: Movement.measurements[:weight])
ghdsu = Movement.find_or_create_by(name: 'GHD Sit-up')
he = Movement.find_or_create_by(name: 'Hip Extensions')
hw = Movement.find_or_create_by(name: 'Handstand Walk')
bj = Movement.find_or_create_by(name: 'Box Jump', measurement: Movement.measurements[:height])
Movement.find_or_create_by(name: 'Wall-ball Shot', measurement: Movement.measurements[:weight])
rest = Movement.find_or_create_by(name: 'Rest', measurement: Movement.measurements[:time])
Movement.find_or_create_by(name: 'Thruster', measurement: Movement.measurements[:weight])
Movement.find_or_create_by(name: 'Chest-to-bar pull-up')
burp = Movement.find_or_create_by(name: 'Burpee')


# LHC 030518
# STRENGTH:
# Frong Squat/Back Squat
# 5 x 4/8@80%
#
# WOD:
# EMOM 10:
# 6 Hang power snatch (95/65) + 30 Du’s
lhc_030518_s = Workout.find_or_create_by(name: 'LHC 03-05-18 Strength') do |workout|
  workout.rounds = 5
  workout.exercises.build(movement: fs, reps: 4, measurement_value: '80%')
  workout.exercises.build(movement: bs, reps: 8, measurement_value: '80%')
  workout.measurement = Workout.measurements[:weight]
end
# Log.find_or_create_by(workout: lhc_030518_s, measurement_value: 145)
lhc_030518_wod = Workout.find_or_create_by(name: 'LHC 03-05-18 WOD') do |workout|
  workout.rounds = 10
  workout.time = 10
  workout.exercises.build(movement: hpc, reps: 6,  male_rx: 95, female_rx: 65)
  workout.exercises.build(movement: du, reps: 30)
  workout.measurement = Workout.measurements[:weight]
end

# LHC 030618
# STRENGTH:
# 1 power clean + 3 Tempo jerks
# Build in 5 sets, then 5 across
#
# WOD:
# 200m Run
# 1:00 Rest
# 400m Run
# 2:00 Rest
# 800m Run
# 4:00 Rest
# 1600m Run
lhc_030618_s = Workout.find_or_create_by(name: 'LHC 03-06-18 Strength') do |workout|
  workout.rounds = 10
  workout.exercises.build(movement: pc, reps: 1)
  workout.exercises.build(movement: tj, reps: 3)
  workout.measurement = Workout.measurements[:weight]
end

lhc_030618_w = Workout.find_or_create_by(name: 'LHC 03-06-18 WOD') do |workout|
  workout.rounds = 1
  workout.exercises.build(movement: run, reps: 1, measurement_value: 200)
  workout.exercises.build(movement: rest, reps: 1, measurement_value: 1)
  workout.exercises.build(movement: run, reps: 1, measurement_value: 400)
  workout.exercises.build(movement: rest, reps: 1, measurement_value: 2)
  workout.exercises.build(movement: run, reps: 1, measurement_value: 800)
  workout.exercises.build(movement: rest, reps: 1, measurement_value: 4)
  workout.exercises.build(movement: run, reps: 1, measurement_value: 1600)
  workout.measurement = Workout.measurements[:time]
end

# LHC 030718
# CORE: 12 min
# 1:00 Evil wheels
# 1:00 Knee tucks on Erg
#
# WOD:
# Complete as many rounds as possible in 20 minutes of:
# 25 burpees
# 15 body-weight back squats
# lhc_030718_s = Workout.find_or_create_by(name: 'LHC 03-07-18 Strength') do |workout|
#   workout.time = 12
#   workout.exercises.build(movement: pc, reps: 1)
#   workout.exercises.build(movement: tj, reps: 3)
#   workout.measurement = Workout.measurements[:weight]
# end

lhc_030718_w = Workout.find_or_create_by(name: 'LHC 03-07-18 WOD') do |workout|
  workout.time = 20
  workout.exercises.build(movement: burp, reps: 25)
  workout.exercises.build(movement: bs, reps: 15, measurement_value: 'body')
  workout.measurement = Workout.measurements[:rounds]
end

# # Sunday 180225
# # 10 rounds for time of:
# # 1 power snatch
# # 3 overhead squats
# # Men: 185 lb.
# # Women: 125 lb.
# sunday = Workout.find_or_create_by(name: 'Sunday 180225') do |workout|
#   workout.rounds = 10
#   workout.exercises.build(movement: ps, reps: 1, male_rx: 185, female_rx: 125)
#   workout.exercises.build(movement: ohs, reps: 3, male_rx: 185, female_rx: 125)
# end
#
# Log.create(workout: sunday, measurement: Log.measurements[:time], measurement_value: 3)
#
# # Saturday 180224
# # 21-18-15-12-9-6-3 reps of:
# # Handstand push-ups
# # L pull-ups
# saturday = Workout.find_or_create_by(name: 'Kelly') do |workout|
#   workout.interval = '21-18-15-12-9-6-3'
#   workout.exercises.build(movement: hspu, reps: 1)
#   workout.exercises.build(movement: lpu, reps: 1)
# end
#
# Log.create(workout: saturday, measurement: Log.measurements[:time], measurement_value: 20)
#
# # Friday 180223
# # Workout 18.1
# # Complete as many rounds as possible in 20 minutes of:
# # 8 toes-to-bars
# # 10 dumbbell hang clean and jerks
# # 14 / 12-cal. row
# friday = Workout.find_or_create_by(name: 'Workout 18.1') do |workout|
#   workout.time = 20
#   workout.exercises.build(movement: t2b, reps: 8)
#   workout.exercises.build(movement: db_hcj, reps: 10, male_rx: 50, female_rx: 30)
#   workout.exercises.build(movement: row, reps: 1,  measurement: 'calories', male_rx: 14, female_rx: 12)
# end
#
# Log.create(workout: friday, measurement: Log.measurements[:rounds], measurement_value: 7.8)
#
# # Wednesday 180221
# # 8 rounds for time of:
# # Run 400 meters
# # Rest 90 seconds
# wednesday = Workout.find_or_create_by(name: 'Wednesday 180221') do |workout|
#   workout.rounds = 8
#   workout.exercises.build(movement: run, reps: 1, measurement: 'meter', measurement_value: 400)
#   workout.exercises.build(movement: rest, reps: 1, measurement: 'second', measurement_value: 90)
# end
#
# Log.create(workout: wednesday, measurement: Log.measurements[:time], measurement_value: 8)
#
# # Tuesday 180220
# # Havana
# # Complete as many rounds as possible in 25 minutes of:
# # 150 double-unders
# # 50 push-ups
# # 15 power cleans
# tuesday_180220 = Workout.find_or_create_by(name: 'Tuesday 180220') do |workout|
#   workout.time = 25
#   workout.exercises.build(movement: du, reps: 150)
#   workout.exercises.build(movement: pu, reps: 50)
#   workout.exercises.build(movement: pc, reps: 15, male_rx: 185, female_rx: 125)
# end
#
# Log.create(workout: tuesday_180220, measurement: Log.measurements[:rounds], measurement_value: 8)
#
# # Monday 180219
# # 4 rounds for time of:
# # 30 GHD sit-ups
# # 30 hip extensions
# # 100-ft. handstand walk
# Workout.find_or_create_by(name: 'Monday 180219') do |workout|
#   workout.rounds = 4
#   workout.exercises.build(movement: ghdsu, reps: 30)
#   workout.exercises.build(movement: he, reps: 30)
#   workout.exercises.build(movement: hw, reps: 1, measurement: 'feet', measurement_value: 100)
# end
#
# # Saturday 180217
# # Five 3-minute rounds of:
# # 10 front squats
# # 10 box jumps
# # Row for max calories
# # Rest 3 minutes between rounds.
# Workout.find_or_create_by(name: 'Saturday 180217') do |workout|
#   workout.rounds = 5
#   workout.time = 3
#   workout.exercises.build(movement: fs, reps: 10, male_rx: 185, female_rx: 125)
#   workout.exercises.build(movement: bj, reps: 10, male_rx: 36, female_rx: 30)
#   workout.exercises.build(movement: row, reps: 1, measurement: 'calories', measurement_value: 'max')
#   workout.exercises.build(movement: rest, reps: 1, measurement: 'minute', measurement_value: 3)
# end
