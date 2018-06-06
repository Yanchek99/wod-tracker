# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
admin = User.find_or_create_by(email: 'admin@wod-tracker.com') do |u|
  u.password = Rails.application.credentials.admin_password
end

# Measurements
calorie = Measurement.find_or_create_by(name: 'calorie')
distance = Measurement.find_or_create_by(name: 'distance')
height = Measurement.find_or_create_by(name: 'height')
rep = Measurement.find_or_create_by(name: 'rep')
round = Measurement.find_or_create_by(name: 'round')
time = Measurement.find_or_create_by(name: 'time')
weight = Measurement.find_or_create_by(name: 'weight')

# Movements
airsquat = Movement.find_or_create_by(name: 'Air Squat', measurement: rep)
bench_press = Movement.find_or_create_by(name: 'Bench Press', measurement: weight)
Movement.find_or_create_by(name: 'Body Blaster', measurement: rep)
backext = Movement.find_or_create_by(name: 'Back Extensions', measurement: rep)
Movement.find_or_create_by(name: 'Body Blaster', measurement: rep)
box_jump = Movement.find_or_create_by(name: 'Box Jump', measurement: rep)
burpee = Movement.find_or_create_by(name: 'Burpee', measurement: rep)
Movement.find_or_create_by(name: 'Over the bar Burpee', measurement: rep)
Movement.find_or_create_by(name: 'Burpee Box Jump', measurement: rep)
chest2bar = Movement.find_or_create_by(name: 'Chest-to-bar pull-up', measurement: rep)
cleanjerk = Movement.find_or_create_by(name: 'Clean and Jerk', measurement: weight)
clean = Movement.find_or_create_by(name: 'Clean Squat', measurement: weight)
deadlift = Movement.find_or_create_by(name: 'Deadlift', measurement: weight)
double_under = Movement.find_or_create_by(name: 'Double Under', measurement: rep)
Movement.find_or_create_by(name: 'Dumbbell Bench Press', measurement: weight)
Movement.find_or_create_by(name: 'Dumbbell Hang Clean and Jerk', measurement: weight)
Movement.find_or_create_by(name: 'Front Squat', measurement: weight)
situp = Movement.find_or_create_by(name: 'Sit-up', measurement: rep)
Movement.find_or_create_by(name: 'GHD Sit-up', measurement: rep)
handstand = Movement.find_or_create_by(name: 'Handstand', measurement: rep)
hspu = Movement.find_or_create_by(name: 'Handstand Push-up', measurement: rep)
Movement.find_or_create_by(name: 'Handstand Walk', measurement: distance)
Movement.find_or_create_by(name: 'Hang Power Snatch', measurement: weight)
Movement.find_or_create_by(name: 'Hip Extensions', measurement: rep)
jumpingjack = Movement.find_or_create_by(name: 'Jumping Jack', measurement: rep)
kbswing = Movement.find_or_create_by(name: 'Kettlebell Swings', measurement: rep)
Movement.find_or_create_by(name: 'Kettlebell Sumo Hi Pull', measurement: rep)
Movement.find_or_create_by(name: 'L Pull-up', measurement: weight)
Movement.find_or_create_by(name: 'Lateral Over Barbell Burpee', measurement: rep)
muscleup = Movement.find_or_create_by(name: 'Muscle-up', measurement: rep)
ohs = Movement.find_or_create_by(name: 'Overhead Squat', measurement: weight)
pistol = Movement.find_or_create_by(name: 'Pistol', measurement: rep)
Movement.find_or_create_by(name: 'Power Clean', measurement: weight)
Movement.find_or_create_by(name: 'Power Snatch', measurement: weight)
Movement.find_or_create_by(name: 'Press Jerk', measurement: weight)
Movement.find_or_create_by(name: 'Push Press', measurement: weight)
pushup = Movement.find_or_create_by(name: 'Push-up', measurement: rep)
pullup = Movement.find_or_create_by(name: 'Pull-up', measurement: rep)
rest = Movement.find_or_create_by(name: 'Rest', measurement: time)
ringdip = Movement.find_or_create_by(name: 'Ring Dip', measurement: rep)
row = Movement.find_or_create_by(name: 'Row', measurement: calorie)
run = Movement.find_or_create_by(name: 'Run', measurement: distance)
Movement.find_or_create_by(name: 'Shoulder to Over Head', measurement: weight)
Movement.find_or_create_by(name: 'Shoulder Press', measurement: weight)
snatch = Movement.find_or_create_by(name: 'Snatch', measurement: weight)
Movement.find_or_create_by(name: 'Sumo Deadlift High Pull', measurement: weight)
Movement.find_or_create_by(name: 'Tempo Jerk', measurement: weight)
thruster = Movement.find_or_create_by(name: 'Thruster', measurement: weight)
Movement.find_or_create_by(name: 'Toes To Bar', measurement: rep)
Movement.find_or_create_by(name: 'Toes to Bar + Pull-up', measurement: rep)
Movement.find_or_create_by(name: 'V-up', measurement: rep)
wallball = Movement.find_or_create_by(name: 'Wall-ball Shot', measurement: rep)

# The Girl WODS

# ==============================================================================
# Angie
# For time
# 100 pull-ups
# 100 push-ups
# 100 sit-ups
# 100 squats
Workout.find_or_create_by(name: 'Angie') do |workout|
  workout.measurement = time
  workout.exercises.build(movement: pullup, reps: 100, measurement: rep)
  workout.exercises.build(movement: pushup, reps: 100, measurement: rep)
  workout.exercises.build(movement: situp, reps: 100, measurement: rep)
  workout.exercises.build(movement: airsquat, reps: 100, measurement: rep)
end

# ==============================================================================
# Barbara
# 5 rounds, each for time
# 20 pull-ups
# 30 push-ups
# 40 sit-ups
# 50 squats
# Rest precisely 3 minutes between each round
Workout.find_or_create_by(name: 'Barbara') do |workout|
  workout.rounds = 5
  workout.measurement = time
  workout.exercises.build(movement: pullup, reps: 20, measurement: rep)
  workout.exercises.build(movement: pushup, reps: 30, measurement: rep)
  workout.exercises.build(movement: situp, reps: 40, measurement: rep)
  workout.exercises.build(movement: airsquat, reps: 50, measurement: rep)
  workout.exercises.build(movement: rest, reps: 1, measurement: time, measurement_value: 3)
end

# ==============================================================================
# Chelsea
# Every minute on the minute for 30 minutes
# 5 pull-ups
# 10 push-ups
# 15 squats
Workout.find_or_create_by(name: 'Chelsea') do |workout|
  workout.rounds = 30
  workout.time = 30
  workout.measurement = rep
  workout.exercises.build(movement: pullup, reps: 5, measurement: rep)
  workout.exercises.build(movement: pushup, reps: 10, measurement: rep)
  workout.exercises.build(movement: airsquat, reps: 15, measurement: rep)
end

# ==============================================================================
# Cindy
# As many rounds as possible in 20 minutes
# 5 pull-ups
# 10 push-ups
# 15 squats
Workout.find_or_create_by(name: 'Cindy') do |workout|
  workout.time = 20
  workout.measurement = round
  workout.exercises.build(movement: pullup, reps: 5, measurement: rep)
  workout.exercises.build(movement: pushup, reps: 10, measurement: rep)
  workout.exercises.build(movement: airsquat, reps: 15, measurement: rep)
end

# ==============================================================================
# Diane
# 21-15-9 reps for time
# 225-lb. deadlifts
# Handstand push-ups
Workout.find_or_create_by(name: 'Diane') do |workout|
  workout.interval = '21-15-9'
  workout.measurement = time
  workout.exercises.build(movement: deadlift, reps: 1, measurement: weight, measurement_value: 225)
  workout.exercises.build(movement: hspu, reps: 1, measurement: rep)
end

# ==============================================================================
# Elizabeth
# 21-15-9 reps for time
# 135-lb. cleans
# Ring dips
Workout.find_or_create_by(name: 'Elizabeth') do |workout|
  workout.interval = '21-15-9'
  workout.measurement = time
  workout.exercises.build(movement: clean, reps: 1, measurement: weight, measurement_value: 135)
  workout.exercises.build(movement: ringdip, reps: 1, measurement: rep)
end

# ==============================================================================
# Fran
# 21-15-9 reps for time
# 95-lb. thrusters
# Pull-ups
Workout.find_or_create_by(name: 'Fran') do |workout|
  workout.interval = '21-15-9'
  workout.measurement = time
  workout.exercises.build(movement: thruster, reps: 1, measurement: weight, measurement_value: 95)
  workout.exercises.build(movement: pullup, reps: 1, measurement: rep)
end

# ==============================================================================
# Grace
# 30 reps for time
# 135-lb. clean and jerks
Workout.find_or_create_by(name: 'Grace') do |workout|
  workout.rounds = 1
  workout.measurement = time
  workout.exercises.build(movement: cleanjerk, reps: 30, measurement: weight, measurement_value: 135)
end

# ==============================================================================
# Helen
# 3 rounds for time
# Run 400 meters
# 1.5-pood kettlebell swings, 21 reps
# 12 pull-ups
Workout.find_or_create_by(name: 'Helen') do |workout|
  workout.rounds = 3
  workout.measurement = time
  workout.exercises.build(movement: run, reps: 1, measurement: distance, measurement_value: 400)
  workout.exercises.build(movement: kbswing, reps: 21, measurement: weight, measurement_value: 53)
  workout.exercises.build(movement: pullup, reps: 12, measurement: rep)
end

# ==============================================================================
# Isabel
# 30 reps for time
# 135-lb. snatches
Workout.find_or_create_by(name: 'Isabel') do |workout|
  workout.rounds = 1
  workout.measurement = time
  workout.exercises.build(movement: snatch, reps: 30, measurement: weight, measurement_value: 135)
end

# ==============================================================================
# Jackie
# For time
# Row 1,000 meters
# 45-lb. thrusters, 50 reps
# 30 pull-ups
Workout.find_or_create_by(name: 'Jackie') do |workout|
  workout.rounds = 1
  workout.measurement = time
  workout.exercises.build(movement: row, reps: 1, measurement: distance, measurement_value: 1000)
  workout.exercises.build(movement: thruster, reps: 50, measurement: weight, measurement_value: 45)
  workout.exercises.build(movement: pullup, reps: 30, measurement: rep)
end

# ==============================================================================
# Karen
# For time
# 150 wall-ball shots, 20-lb. ball
Workout.find_or_create_by(name: 'Jackie') do |workout|
  workout.rounds = 1
  workout.measurement = time
  workout.exercises.build(movement: wallball, reps: 150, measurement: weight, measurement_value: 20)
end

# ==============================================================================
# Linda (a.k.a. 3 Bars of Death)
# 10-9-8-7-6-5-4-3-2-1 reps for time
# 1 1/2 body-weight deadlifts
# Body-weight bench presses
# 3/4 body-weight cleans
Workout.find_or_create_by(name: 'Linda') do |workout|
  workout.interval = '10-9-8-7-6-5-4-3-2-1'
  workout.measurement = time
  workout.exercises.build(movement: deadlift, reps: 1, measurement: weight, measurement_value: '1 1/2 body weight')
  workout.exercises.build(movement: bench_press, reps: 1, measurement: weight, measurement_value: 'body weight')
  workout.exercises.build(movement: clean, reps: 1, measurement: weight, measurement_value: '3/4 body weight')
end

# ==============================================================================
# Mary
# As many rounds as possible in 20 minutes
# 5 handstand push-ups
# 10 1-legged squats
# 15 pull-ups
Workout.find_or_create_by(name: 'Mary') do |workout|
  workout.time = 20
  workout.measurement = round
  workout.exercises.build(movement: hspu, reps: 5, measurement: rep)
  workout.exercises.build(movement: pistol, reps: 10, measurement: rep)
  workout.exercises.build(movement: pullup, reps: 15, measurement: rep)
end

# ==============================================================================
# Nancy
# 5 rounds for time
# Run 400 meters
# 95-lb. overhead squats, 15 reps
Workout.find_or_create_by(name: 'Nancy') do |workout|
  workout.rounds = 5
  workout.measurement = time
  workout.exercises.build(movement: run, reps: 1, measurement: distance, measurement_value: 400)
  workout.exercises.build(movement: ohs, reps: 15, measurement: weight, measurement_value: 95)
end

# The New Girls WODS

# ==============================================================================
# Annie
# 50-40-30-20-10 reps for time
# Double-unders
# Sit-ups
Workout.find_or_create_by(name: 'Annie') do |workout|
  workout.interval = '50-40-30-20-10'
  workout.measurement = time
  workout.exercises.build(movement: double_under, reps: 1, measurement: rep)
  workout.exercises.build(movement: situp, reps: 1, measurement: rep)
end

# ==============================================================================
# Eva
# 5 rounds for time
# Run 800 meters
# 2-pood kettlebell swings, 30 reps
# 30 pull-ups
Workout.find_or_create_by(name: 'Eva') do |workout|
  workout.rounds = 5
  workout.measurement = time
  workout.exercises.build(movement: run, reps: 1, measurement: distance, measurement_value: 800)
  workout.exercises.build(movement: kbswing, reps: 30, measurement: weight, measurement_value: 70)
  workout.exercises.build(movement: pullup, reps: 30, measurement: rep)
end

# ==============================================================================
# Kelly
# 5 rounds for time
# Run 400 meters
# 30 box jumps, 24-inch box
# 30 wall-ball shots, 20-lb. ball
Workout.find_or_create_by(name: 'Kelly') do |workout|
  workout.rounds = 5
  workout.measurement = time
  workout.exercises.build(movement: run, reps: 1, measurement: distance, measurement_value: 400)
  workout.exercises.build(movement: box_jump, reps: 30, measurement: rep)
  workout.exercises.build(movement: wallball, reps: 30, measurement: rep)
end

# ==============================================================================
# Lynne
# 5 rounds for max reps. There is no time component to this workout, although some versions Rx the movements as a couplet.
# Body-weight bench press
# Pull-ups
Workout.find_or_create_by(name: 'Lynne') do |workout|
  workout.rounds = 5
  workout.measurement = rep
  workout.exercises.build(movement: bench_press, measurement: weight, measurement_value: 'body weight')
  workout.exercises.build(movement: pullup, reps: 30, measurement: rep)
end

# ==============================================================================
# Nicole
# As many rounds as possible in 20 minutes.
# Note number of pull-ups completed for each round.
# Run 400 meters
# Max-reps pull-ups
Workout.find_or_create_by(name: 'Nicole') do |workout|
  workout.time = 20
  workout.measurement = round
  workout.exercises.build(movement: run, reps: 1, measurement: distance, measurement_value: 400)
  workout.exercises.build(movement: pullup, measurement: rep)
end

# ==============================================================================
# Amanda
# 9-7-5 reps for time
# Muscle-ups
# 135-lb. snatches
Workout.find_or_create_by(name: 'Amanda') do |workout|
  workout.interval = '50-40-30-20-10'
  workout.measurement = time
  workout.exercises.build(movement: muscleup, reps: 1, measurement: rep)
  workout.exercises.build(movement: snatch, reps: 1, measurement: weight, measurement_value: 135)
end

# ==============================================================================
# Gwen
# For load
# Clean and jerk 15-12-9 reps
# Touch and go at floor only. Even a re-grip off the floor is a foul. No dumping. Use same load for each set. Rest as needed between sets.
Workout.find_or_create_by(name: 'Gwen') do |workout|
  workout.interval = '15-12-9'
  workout.measurement = weight
  workout.exercises.build(movement: cleanjerk, reps: 1, measurement: weight)
end

# ==============================================================================
# Marguerita
# 50 reps for time
# Burpee/Push-up/Jumping-Jack/Sit-up/Handstand
Workout.find_or_create_by(name: 'Marguerita') do |workout|
  workout.rounds = 50
  workout.measurement = time
  workout.exercises.build(movement: burpee, reps: 1, measurement: rep)
  workout.exercises.build(movement: pushup, reps: 1, measurement: rep)
  workout.exercises.build(movement: jumpingjack, reps: 1, measurement: rep)
  workout.exercises.build(movement: situp, reps: 1, measurement: rep)
  workout.exercises.build(movement: handstand, reps: 1, measurement: rep)
end

# ==============================================================================
# Candy
# 5 rounds for time
# 20 pull-ups
# 40 push-ups
# 60 squats
Workout.find_or_create_by(name: 'Candy') do |workout|
  workout.rounds = 5
  workout.measurement = time
  workout.exercises.build(movement: pullup, reps: 20, measurement: rep)
  workout.exercises.build(movement: pushup, reps: 40, measurement: rep)
  workout.exercises.build(movement: airsquat, reps: 60, measurement: rep)
end

# ==============================================================================
# Maggie
# 5 rounds for time
# 20 handstand push-ups
# 40 pull-ups
# 60 one-legged squats, alternating legs
Workout.find_or_create_by(name: 'Maggie') do |workout|
  workout.rounds = 5
  workout.measurement = time
  workout.exercises.build(movement: hspu, reps: 20, measurement: rep)
  workout.exercises.build(movement: pullup, reps: 40, measurement: rep)
  workout.exercises.build(movement: pistol, reps: 60, measurement: rep)
end

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
Workout.find_or_create_by(name: 'Hope') do |workout|
  workout.rounds = 3
  workout.time = 18
  workout.measurement = rep
  workout.exercises.build(movement: burpee, measurement: rep)
  workout.exercises.build(movement: snatch, measurement: weight, measurement_value: 75)
  workout.exercises.build(movement: box_jump, measurement: rep)
  workout.exercises.build(movement: thruster, measurement: weight, measurement_value: 75)
  workout.exercises.build(movement: chest2bar, measurement: rep)
  workout.exercises.build(movement: rest, reps: 1, measurement: time, measurement_value: 1)
end

# Hero WODS

# ==============================================================================
# JT
# 21-15-9 reps for time
# Handstand push-ups
# Ring dips
# Push-ups
Workout.find_or_create_by(name: 'JT') do |workout|
  workout.interval = '21-15-9'
  workout.measurement = time
  workout.exercises.build(movement: hspu, reps: 1, measurement: rep)
  workout.exercises.build(movement: ringdip, reps: 1, measurement: rep)
  workout.exercises.build(movement: pushup, reps: 1, measurement: rep)
end


# ==============================================================================
# Michael
# 3 rounds for time
# Run 800 meters
# 50 back extensions
# 50 sit-ups
Workout.find_or_create_by(name: 'Michael') do |workout|
  workout.rounds = 3
  workout.measurement = time
  workout.exercises.build(movement: run, reps: 1, measurement: distance, measurement_value: 800)
  workout.exercises.build(movement: backext, reps: 50, measurement: rep)
  workout.exercises.build(movement: situp, reps: 50, measurement: rep)
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
  workout.measurement = time
  workout.exercises.build(movement: run, reps: 1, measurement: distance, measurement_value: 1600)
  workout.exercises.build(movement: pullup, reps: 100, measurement: rep)
  workout.exercises.build(movement: pushup, reps: 200, measurement: rep)
  workout.exercises.build(movement: airsquat, reps: 300, measurement: rep)
  workout.exercises.build(movement: run, reps: 1, measurement: distance, measurement_value: 1600)
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
  workout.measurement = time
  workout.exercises.build(movement: pullup, reps: 50, measurement: rep)
  workout.exercises.build(movement: run, reps: 1, measurement: distance, measurement_value: 400)
  workout.exercises.build(movement: thruster, reps: 21, measurement: weight, measurement_value: 95)
  workout.exercises.build(movement: run, reps: 1, measurement: distance, measurement_value: 800)
  workout.exercises.build(movement: thruster, reps: 21, measurement: weight, measurement_value: 95)
  workout.exercises.build(movement: run, reps: 1, measurement: distance, measurement_value: 400)
  workout.exercises.build(movement: pullup, reps: 50, measurement: rep)
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
  workout.measurement = time
  workout.exercises.build(movement: ohs, reps: 21, measurement: weight, measurement_value: 95)
  workout.exercises.build(movement: pullup, reps: 42, measurement: rep)
  workout.exercises.build(movement: ohs, reps: 15, measurement: weight, measurement_value: 95)
  workout.exercises.build(movement: pullup, reps: 30, measurement: rep)
  workout.exercises.build(movement: ohs, reps: 9, measurement: weight, measurement_value: 95)
  workout.exercises.build(movement: pullup, reps: 18, measurement: rep)
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
  workout.measurement = time
  workout.exercises.build(movement: airsquat, reps: 100, measurement: rep)
  workout.exercises.build(movement: muscleup, reps: 5, measurement: rep)
  workout.exercises.build(movement: airsquat, reps: 75, measurement: rep)
  workout.exercises.build(movement: muscleup, reps: 10, measurement: rep)
  workout.exercises.build(movement: airsquat, reps: 50, measurement: rep)
  workout.exercises.build(movement: muscleup, reps: 15, measurement: rep)
  workout.exercises.build(movement: airsquat, reps: 25, measurement: rep)
  workout.exercises.build(movement: muscleup, reps: 20, measurement: rep)
end
