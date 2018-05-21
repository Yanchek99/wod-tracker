# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
matt = User.find_or_create_by(email: 'matt.yanchek@gmail.com') do |u|
  u.password = 'cr0ssF!t'
end

# Measurements
weight = Measurement.find_or_create_by(name: 'weight')
time = Measurement.find_or_create_by(name: 'time')
calorie = Measurement.find_or_create_by(name: 'calorie')
rep = Measurement.find_or_create_by(name: 'rep')
round = Measurement.find_or_create_by(name: 'round')
distance = Measurement.find_or_create_by(name: 'distance')
height = Measurement.find_or_create_by(name: 'height')

# Movements
hspu = Movement.find_or_create_by(name: 'Handstand Push-up', measurement: weight)
lpu = Movement.find_or_create_by(name: 'L Pull-up', measurement: weight)
t2b = Movement.find_or_create_by(name: 'Toes To Bar', measurement: rep)
t2bpu = Movement.find_or_create_by(name: 'Toes to Bar + Pull-up', measurement: rep)
db_hcj = Movement.find_or_create_by(name: 'Dumbbell Hang Clean and Jerk', measurement: weight)
row = Movement.find_or_create_by(name: 'Row', measurement: calorie)
run = Movement.find_or_create_by(name: 'Run', measurement: distance)
du = Movement.find_or_create_by(name: 'Double Under', measurement: rep)
pu = Movement.find_or_create_by(name: 'Push-up', measurement: rep)
dl = Movement.find_or_create_by(name: 'Deadlift', measurement: weight)
tj = Movement.find_or_create_by(name: 'Tempo Jerk', measurement: weight)
pc = Movement.find_or_create_by(name: 'Power Clean', measurement: weight)
snatch = Movement.find_or_create_by(name: 'Snatch', measurement: weight)
ps = Movement.find_or_create_by(name: 'Power Snatch', measurement: weight)
hpc = Movement.find_or_create_by(name: 'Hang Power Snatch', measurement: weight)
fs = Movement.find_or_create_by(name: 'Front Squat', measurement: weight)
bs = Movement.find_or_create_by(name: 'Back Squat', measurement: weight)
ohs = Movement.find_or_create_by(name: 'Overhead Squat', measurement: weight)
ghdsu = Movement.find_or_create_by(name: 'GHD Sit-up', measurement: rep)
he = Movement.find_or_create_by(name: 'Hip Extensions', measurement: rep)
hw = Movement.find_or_create_by(name: 'Handstand Walk', measurement: distance)
bj = Movement.find_or_create_by(name: 'Box Jump', measurement: rep)
bbj = Movement.find_or_create_by(name: 'Burpee Box Jump', measurement: rep)
wb = Movement.find_or_create_by(name: 'Wall-ball Shot', measurement: rep)
rest = Movement.find_or_create_by(name: 'Rest', measurement: time)
Movement.find_or_create_by(name: 'Thruster', measurement: weight)
Movement.find_or_create_by(name: 'Chest-to-bar pull-up', measurement: rep)
Movement.find_or_create_by(name: 'V-up', measurement: rep)
burp = Movement.find_or_create_by(name: 'Burpee', measurement: rep)
Movement.find_or_create_by(name: 'Lateral Over Barbell Burpee', measurement: rep)
pistol = Movement.find_or_create_by(name: 'Pistol', measurement: rep)
sdlhp = Movement.find_or_create_by(name: 'Sumo Deadlift High Pull', measurement: weight)
Movement.find_or_create_by(name: 'Shoulder Press', measurement: weight)
pp = Movement.find_or_create_by(name: 'Push Press', measurement: weight)
Movement.find_or_create_by(name: 'Press Jerk', measurement: weight)
Movement.find_or_create_by(name: 'Shoulder to Over Head', measurement: weight)
Movement.find_or_create_by(name: 'Kettlebell Swings', measurement: rep)
Movement.find_or_create_by(name: 'Kettlebell Sumo Hi Pull', measurement: rep)

# http://www.lakehillscrossfit.com/41018-2/
# ==============================================================================
Workout.find_or_create_by(name: 'LHC-041018-S') do |workout|
  workout.rounds = 3
  workout.measurement = weight
  workout.exercises.build(movement: fs, reps: 4, measurement_value: '80%')
  workout.exercises.build(movement: bs, reps: 4, measurement_value: '80%')
end

Workout.find_or_create_by(name: 'LHC-041018') do |workout|
  workout.time = 14
  workout.measurement = round
  workout.exercises.build(movement: ps, reps: 6, male_rx: 135, female_rx: 95)
  workout.exercises.build(movement: pistol, reps: 12)
  workout.exercises.build(movement: du, reps: 30)
end
# ==============================================================================

# http://www.lakehillscrossfit.com/41118-2/
# ==============================================================================
Workout.find_or_create_by(name: 'LHC-041118') do |workout|
  workout.rounds = 1
  workout.measurement = time
  workout.exercises.build(movement: row, reps: 1, male_rx: 20, female_rx: 15)
  workout.exercises.build(movement: sdlhp, reps: 50, male_rx: 95, female_rx: 65)
  workout.exercises.build(movement: row, reps: 1, male_rx: 20, female_rx: 15)
  workout.exercises.build(movement: ohs, reps: 50, male_rx: 95, female_rx: 65)
  workout.exercises.build(movement: row, reps: 1, male_rx: 20, female_rx: 15)
  workout.exercises.build(movement: pp, reps: 50, male_rx: 95, female_rx: 65)
  workout.exercises.build(movement: row, reps: 1, male_rx: 20, female_rx: 15)
end
# ==============================================================================

# http://www.lakehillscrossfit.com/41218-2/
# ==============================================================================
Workout.find_or_create_by(name: 'LHC-041218-S') do |workout|
  workout.rounds = 1
  workout.time = 20
  workout.measurement = weight
  workout.exercises.build(movement: snatch, reps: 1)
  workout.exercises.build(movement: ohs, reps: 1)
end

Workout.find_or_create_by(name: 'LHC-041218') do |workout|
  workout.rounds = 5
  workout.measurement = time
  workout.exercises.build(movement: t2bpu, reps: 10)
  workout.exercises.build(movement: run, reps: 1, measurement_value: 200)
end
# ==============================================================================

# http://www.lakehillscrossfit.com/41318-2/
# ==============================================================================
Workout.find_or_create_by(name: 'LHC-041318-S') do |workout|
  workout.rounds = 4
  workout.measurement = weight
  workout.exercises.build(movement: dl, reps: 4)
end

Workout.find_or_create_by(name: 'LHC-041318') do |workout|
  workout.time = 12
  workout.measurement = rep
  workout.exercises.build(movement: wb, reps: 2, male_rx: 20, female_rx: 14)
  workout.exercises.build(movement: bbj, reps: 2)
  workout.exercises.build(movement: wb, reps: 4, male_rx: 20, female_rx: 14)
  workout.exercises.build(movement: bbj, reps: 4)
  workout.exercises.build(movement: wb, reps: 6, male_rx: 20, female_rx: 14)
  workout.exercises.build(movement: bbj, reps: 6)
  workout.exercises.build(movement: wb, reps: 8, male_rx: 20, female_rx: 14)
  workout.exercises.build(movement: bbj, reps: 8)
  workout.exercises.build(movement: wb, reps: 10, male_rx: 20, female_rx: 14)
  workout.exercises.build(movement: bbj, reps: 10)
  workout.exercises.build(movement: wb, reps: 12, male_rx: 20, female_rx: 14)
  workout.exercises.build(movement: bbj, reps: 12)
  workout.exercises.build(movement: wb, reps: 14, male_rx: 20, female_rx: 14)
  workout.exercises.build(movement: bbj, reps: 14)
  workout.exercises.build(movement: wb, reps: 16, male_rx: 20, female_rx: 14)
  workout.exercises.build(movement: bbj, reps: 16)
  workout.exercises.build(movement: wb, reps: 18, male_rx: 20, female_rx: 14)
  workout.exercises.build(movement: bbj, reps: 18)
end
# ==============================================================================

# http://www.lakehillscrossfit.com/41418-2/
# ==============================================================================
Workout.find_or_create_by(name: 'Havana') do |workout|
  workout.time = 25
  workout.measurement = round
  workout.exercises.build(movement: du, reps: 150)
  workout.exercises.build(movement: pu, reps: 50)
  workout.exercises.build(movement: pc, reps: 15, male_rx: 185, female_rx: 125)
end
# ==============================================================================
