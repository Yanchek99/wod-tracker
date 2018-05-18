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


hspu = Movement.find_or_create_by(name: 'Handstand Push-up', measurement: Movement.measurements[:weight])
lpu = Movement.find_or_create_by(name: 'L Pull-up', measurement: Movement.measurements[:weight])
t2b = Movement.find_or_create_by(name: 'Toes To Bar')
t2bpu = Movement.find_or_create_by(name: 'Toes to Bar + Pull-up')
db_hcj = Movement.find_or_create_by(name: 'Dumbbell Hang Clean and Jerk', measurement: Movement.measurements[:weight])
row = Movement.find_or_create_by(name: 'Row')
run = Movement.find_or_create_by(name: 'Run', measurement: Movement.measurements[:distance])
du = Movement.find_or_create_by(name: 'Double Under')
pu = Movement.find_or_create_by(name: 'Push-up')
dl = Movement.find_or_create_by(name: 'Deadlift', measurement: Movement.measurements[:weight])
tj = Movement.find_or_create_by(name: 'Tempo Jerk', measurement: Movement.measurements[:weight])
pc = Movement.find_or_create_by(name: 'Power Clean', measurement: Movement.measurements[:weight])
snatch = Movement.find_or_create_by(name: 'Snatch', measurement: Movement.measurements[:weight])
ps = Movement.find_or_create_by(name: 'Power Snatch', measurement: Movement.measurements[:weight])
hpc = Movement.find_or_create_by(name: 'Hang Power Snatch', measurement: Movement.measurements[:weight])
fs = Movement.find_or_create_by(name: 'Front Squat', measurement: Movement.measurements[:weight])
bs = Movement.find_or_create_by(name: 'Back Squat', measurement: Movement.measurements[:weight])
ohs = Movement.find_or_create_by(name: 'Overhead Squat', measurement: Movement.measurements[:weight])
ghdsu = Movement.find_or_create_by(name: 'GHD Sit-up')
he = Movement.find_or_create_by(name: 'Hip Extensions')
hw = Movement.find_or_create_by(name: 'Handstand Walk')
bj = Movement.find_or_create_by(name: 'Box Jump', measurement: Movement.measurements[:height])
bbj = Movement.find_or_create_by(name: 'Burpee Box Jump')
wb = Movement.find_or_create_by(name: 'Wall-ball Shot', measurement: Movement.measurements[:weight])
rest = Movement.find_or_create_by(name: 'Rest', measurement: Movement.measurements[:time])
Movement.find_or_create_by(name: 'Thruster', measurement: Movement.measurements[:weight])
Movement.find_or_create_by(name: 'Chest-to-bar pull-up')
Movement.find_or_create_by(name: 'V-up')
burp = Movement.find_or_create_by(name: 'Burpee')
Movement.find_or_create_by(name: 'Lateral Over Barbell Burpee')
pistol = Movement.find_or_create_by(name: 'Pistol')
sdlhp = Movement.find_or_create_by(name: 'Sumo Deadlift High Pull', measurement: Movement.measurements[:weight])
Movement.find_or_create_by(name: 'Shoulder Press', measurement: Movement.measurements[:weight])
Movement.find_or_create_by(name: 'Push Press', measurement: Movement.measurements[:weight])
Movement.find_or_create_by(name: 'Press Jerk', measurement: Movement.measurements[:weight])
Movement.find_or_create_by(name: 'Shoulder to Over Head', measurement: Movement.measurements[:weight])
Movement.find_or_create_by(name: 'Kettlebell Swings')

# http://www.lakehillscrossfit.com/41018-2/
# ==============================================================================
Workout.find_or_create_by(name: 'LHC-041018-S') do |workout|
  workout.rounds = 3
  workout.exercises.build(movement: fs, reps: 4, measurement_value: '80%')
  workout.exercises.build(movement: bs, reps: 4, measurement_value: '80%')
end

Workout.find_or_create_by(name: 'LHC-041018') do |workout|
  workout.time = 14
  workout.exercises.build(movement: ps, reps: 6, male_rx: 135, female_rx: 95)
  workout.exercises.build(movement: pistol, reps: 12)
  workout.exercises.build(movement: du, reps: 30)
end
# ==============================================================================

# http://www.lakehillscrossfit.com/41118-2/
# ==============================================================================
Workout.find_or_create_by(name: 'LHC-041118') do |workout|
  workout.rounds = 1
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
  workout.exercises.build(movement: snatch, reps: 1)
  workout.exercises.build(movement: ohs, reps: 1)
end

Workout.find_or_create_by(name: 'LHC-041218') do |workout|
  workout.rounds = 5
  workout.exercises.build(movement: t2bpu, reps: 10)
  workout.exercises.build(movement: run, reps: 1, measurement_value: 200)
end
# ==============================================================================

# http://www.lakehillscrossfit.com/41318-2/
# ==============================================================================
Workout.find_or_create_by(name: 'LHC-041318-S') do |workout|
  workout.rounds = 4
  workout.exercises.build(movement: dl, reps: 4)
end

Workout.find_or_create_by(name: 'LHC-041318') do |workout|
  workout.time = 12
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

# http://www.lakehillscrossfit.com/41318-2/
# ==============================================================================
Workout.find_or_create_by(name: 'LHC-041318-S') do |workout|
  workout.rounds = 4
  workout.exercises.build(movement: dl, reps: 4)
end

Workout.find_or_create_by(name: 'LHC-041318') do |workout|
  workout.time = 12
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
  workout.exercises.build(movement: du, reps: 150)
  workout.exercises.build(movement: pu, reps: 50)
  workout.exercises.build(movement: pc, reps: 15, male_rx: 185, female_rx: 125)
end
# ==============================================================================
