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
Movement.find_or_create_by(name: 'Dip', measurement: rep)
double_under = Movement.find_or_create_by(name: 'Double Under', measurement: rep)
Movement.find_or_create_by(name: 'Dumbbell Bench Press', measurement: weight)
Movement.find_or_create_by(name: 'Dumbbell Hang Clean and Jerk', measurement: weight)
Movement.find_or_create_by(name: 'Dumbbell Bell Step-up', measurement: rep)
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
Movement.find_or_create_by(name: 'L Sit Hold on Matador', measurement: time)
Movement.find_or_create_by(name: 'Lateral Over Barbell Burpee', measurement: rep)
Movement.find_or_create_by(name: 'Lunge', measurement: rep)
Movement.find_or_create_by(name: 'Lunge with plate overhead', measurement: rep)
Movement.find_or_create_by(name: 'Bar Muscle-up', measurement: rep)
muscleup = Movement.find_or_create_by(name: 'Muscle-up', measurement: rep)
ohs = Movement.find_or_create_by(name: 'Overhead Squat', measurement: weight)
pistol = Movement.find_or_create_by(name: 'Pistol', measurement: rep)
Movement.find_or_create_by(name: 'Power Clean', measurement: weight)
Movement.find_or_create_by(name: 'Power Snatch', measurement: weight)
Movement.find_or_create_by(name: 'Press Jerk', measurement: weight)
push_press = Movement.find_or_create_by(name: 'Push Press', measurement: weight)
pushup = Movement.find_or_create_by(name: 'Push-up', measurement: rep)
pullup = Movement.find_or_create_by(name: 'Pull-up', measurement: rep)
Movement.find_or_create_by(name: 'Strict Pull-up', measurement: rep)
rest = Movement.find_or_create_by(name: 'Rest', measurement: time)
Movement.find_or_create_by(name: 'Renegade Row', measurement: rep)
ringdip = Movement.find_or_create_by(name: 'Ring Dip', measurement: rep)
Movement.find_or_create_by(name: 'Rope Climb', measurement: rep)
row = Movement.find_or_create_by(name: 'Row', measurement: calorie)
run = Movement.find_or_create_by(name: 'Run', measurement: distance)
Movement.find_or_create_by(name: 'Shoulder to Over Head', measurement: weight)
Movement.find_or_create_by(name: 'Shoulder Press', measurement: weight)
Movement.find_or_create_by(name: 'Sled Pull', measurement: distance)
snatch = Movement.find_or_create_by(name: 'Snatch', measurement: weight)
sumo_deadlift_hight_pull = Movement.find_or_create_by(name: 'Sumo Deadlift High Pull', measurement: weight)
Movement.find_or_create_by(name: 'Swim', measurement: distance)
Movement.find_or_create_by(name: 'Tempo Jerk', measurement: weight)
thruster = Movement.find_or_create_by(name: 'Thruster', measurement: weight)
Movement.find_or_create_by(name: 'Toes To Bar', measurement: rep)
Movement.find_or_create_by(name: 'Toes to Bar + Pull-up', measurement: rep)
Movement.find_or_create_by(name: 'V-up', measurement: rep)
wallball = Movement.find_or_create_by(name: 'Wall-ball Shot', measurement: rep)

# Programs
cfj = Program.find_or_create_by(name: 'Crossfit Journal')


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
  workout.measurement = rep
  workout.rounds = 3
  workout.time = 18
  workout.notes = 'In this workout you move from each of 5 stations after a minute.'\
          ' This is a 5-minute round after which a 1-minute break is allowed before repeating.'\
          ' The clock does not reset or stop between exercises.'\
          ' On the call of "rotate," the athlete(s) must move to the next station immediately for a good score.'\
          ' One point is given for each rep, except on the rower where each calorie is 1 point.'
  workout.exercises.build(movement: wallball) do |e|
    e.metrics.build(measurement: :rep)
    e.metrics.build(measurement: :time, value: '1:00')
    e.metrics.build(measurement: :weight, value: 20)
  end
  workout.exercises.build(movement: sumo_deadlift_hight_pull) do |e|
    e.metrics.build(measurement: :rep)
    e.metrics.build(measurement: :time, value: '1:00')
    e.metrics.build(measurement: :weight, value: 75)
  end
  workout.exercises.build(movement: box_jump) do |e|
    e.metrics.build(measurement: :rep)
    e.metrics.build(measurement: :time, value: '1:00')
    e.metrics.build(measurement: :height, value: 20)
  end
  workout.exercises.build(movement: push_press) do |e|
    e.metrics.build(measurement: :rep)
    e.metrics.build(measurement: :time, value: '1:00')
    e.metrics.build(measurement: :weight, value: 75)
  end
  workout.exercises.build(movement: row) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :calorie)
    e.metrics.build(measurement: :time, value: '1:00')
  end
  workout.exercises.build(movement: rest) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :time, value: '1:00')
  end
end

cfj.schedules.find_or_create_by(workout: fight_gone_bad, posted_at: '01-01-2018')

# ==============================================================================
# The Girl WODS
# ==============================================================================
# Angie
# For time
# 100 pull-ups
# 100 push-ups
# 100 sit-ups
# 100 squats
angie = Workout.find_or_create_by(name: 'Angie') do |workout|
  workout.measurement = time
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 100)
  end
  workout.exercises.build(movement: pushup) do |e|
    e.metrics.build(measurement: :rep, value: 100)
  end
  workout.exercises.build(movement: situp) do |e|
    e.metrics.build(measurement: :rep, value: 100)
  end
  workout.exercises.build(movement: airsquat) do |e|
    e.metrics.build(measurement: :rep, value: 100)
  end
end

cfj.schedules.find_or_create_by(workout: angie, posted_at: '02-01-2018')

# ==============================================================================
# Barbara
# 5 rounds, each for time
# 20 pull-ups
# 30 push-ups
# 40 sit-ups
# 50 squats
# Rest precisely 3 minutes between each round
barbara = Workout.find_or_create_by(name: 'Barbara') do |workout|
  workout.rounds = 5
  workout.measurement = time
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 20)
  end
  workout.exercises.build(movement: pushup) do |e|
    e.metrics.build(measurement: :rep, value: 30)
  end
  workout.exercises.build(movement: situp) do |e|
    e.metrics.build(measurement: :rep, value: 40)
  end
  workout.exercises.build(movement: airsquat) do |e|
    e.metrics.build(measurement: :rep, value: 50)
  end
  workout.exercises.build(movement: rest) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :time, value: '3:00')
  end
end

cfj.schedules.find_or_create_by(workout: barbara, posted_at: '30-06-2017')

# ==============================================================================
# Chelsea
# Every minute on the minute for 30 minutes
# 5 pull-ups
# 10 push-ups
# 15 squats
chelsea = Workout.find_or_create_by(name: 'Chelsea') do |workout|
  workout.rounds = 30
  workout.time = 30
  workout.measurement = rep
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 5)
  end
  workout.exercises.build(movement: pushup) do |e|
    e.metrics.build(measurement: :rep, value: 10)
  end
  workout.exercises.build(movement: airsquat) do |e|
    e.metrics.build(measurement: :rep, value: 15)
  end
end

cfj.schedules.find_or_create_by(workout: chelsea, posted_at: '04-09-2015')

# ==============================================================================
# Cindy
# As many rounds as possible in 20 minutes
# 5 pull-ups
# 10 push-ups
# 15 squats
cindy = Workout.find_or_create_by(name: 'Cindy') do |workout|
  workout.time = 20
  workout.measurement = round
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 5)
  end
  workout.exercises.build(movement: pushup) do |e|
    e.metrics.build(measurement: :rep, value: 10)
  end
  workout.exercises.build(movement: airsquat) do |e|
    e.metrics.build(measurement: :rep, value: 15)
  end
end

cfj.schedules.find_or_create_by(workout: cindy, posted_at: '12-08-2017')

# ==============================================================================
# Diane
# 21-15-9 reps for time
# 225-lb. deadlifts
# Handstand push-ups
diane = Workout.find_or_create_by(name: 'Diane') do |workout|
  workout.interval = '21-15-9'
  workout.measurement = time
  workout.exercises.build(movement: deadlift) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :weight, value: 225)
  end
  workout.exercises.build(movement: hspu) do |e|
    e.metrics.build(measurement: :rep, value: 1)
  end
end

cfj.schedules.find_or_create_by(workout: diane, posted_at: '13-12-2015')

# ==============================================================================
# Elizabeth
# 21-15-9 reps for time
# 135-lb. cleans
# Ring dips
elizabeth = Workout.find_or_create_by(name: 'Elizabeth') do |workout|
  workout.interval = '21-15-9'
  workout.measurement = time
  workout.exercises.build(movement: clean) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :weight, value: 135)
  end
  workout.exercises.build(movement: ringdip) do |e|
    e.metrics.build(measurement: :rep, value: 1)
  end
end

cfj.schedules.find_or_create_by(workout: elizabeth, posted_at: '05-04-2018')

# ==============================================================================
# Fran
# 21-15-9 reps for time
# 95-lb. thrusters
# Pull-ups
fran = Workout.find_or_create_by(name: 'Fran') do |workout|
  workout.interval = '21-15-9'
  workout.measurement = time
  workout.exercises.build(movement: thruster) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :weight, value: 95)
  end
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 1)
  end
end

cfj.schedules.find_or_create_by(workout: fran, posted_at: '17-11-2017')

# ==============================================================================
# Grace
# 30 reps for time
# 135-lb. clean and jerks
grace = Workout.find_or_create_by(name: 'Grace') do |workout|
  workout.rounds = 1
  workout.measurement = time
  workout.exercises.build(movement: cleanjerk) do |e|
    e.metrics.build(measurement: :rep, value: 30)
    e.metrics.build(measurement: :weight, value: 135)
  end
end

 cfj.schedules.find_or_create_by(workout: grace, posted_at: '13-06-2018')

# ==============================================================================
# Helen
# 3 rounds for time
# Run 400 meters
# 1.5-pood kettlebell swings, 21 reps
# 12 pull-ups
helen = Workout.find_or_create_by(name: 'Helen') do |workout|
  workout.rounds = 3
  workout.measurement = time
  workout.exercises.build(movement: run) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :distance, value: 400)
  end
  workout.exercises.build(movement: kbswing) do |e|
    e.metrics.build(measurement: :rep, value: 21)
    e.metrics.build(measurement: :weight, value: 53)
  end
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 1)
  end
end

cfj.schedules.find_or_create_by(workout: helen, posted_at: '15-05-2018')

# ==============================================================================
# Isabel
# 30 reps for time
# 135-lb. snatches
isabel = Workout.find_or_create_by(name: 'Isabel') do |workout|
  workout.rounds = 1
  workout.measurement = time
  workout.exercises.build(movement: snatch) do |e|
    e.metrics.build(measurement: :rep, value: 30)
    e.metrics.build(measurement: :weight, value: 135)
  end
end

cfj.schedules.find_or_create_by(workout: isabel, posted_at: '13-06-2018')

# ==============================================================================
# Jackie
# For time
# Row 1,000 meters
# 45-lb. thrusters, 50 reps
# 30 pull-ups
jackie = Workout.find_or_create_by(name: 'Jackie') do |workout|
  workout.rounds = 1
  workout.measurement = time
  workout.exercises.build(movement: row) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :distance, value: 1000)
  end
  workout.exercises.build(movement: thruster) do |e|
    e.metrics.build(measurement: :rep, value: 50)
    e.metrics.build(measurement: :weight, value: 45)
  end
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 30)
  end
end

cfj.schedules.find_or_create_by(workout: jackie, posted_at: '15-05-2015')

# ==============================================================================
# Karen
# For time
# 150 wall-ball shots, 20-lb. ball
karen = Workout.find_or_create_by(name: 'Karen') do |workout|
  workout.rounds = 1
  workout.measurement = time
  workout.exercises.build(movement: wallball) do |e|
    e.metrics.build(measurement: :rep, value: 150)
    e.metrics.build(measurement: :weight, value: 20)
  end
end

cfj.schedules.find_or_create_by(workout: karen, posted_at: '05-01-2017')

# ==============================================================================
# Linda (a.k.a. 3 Bars of Death)
# 10-9-8-7-6-5-4-3-2-1 reps for time
# 1 1/2 body-weight deadlifts
# Body-weight bench presses
# 3/4 body-weight cleans
linda = Workout.find_or_create_by(name: 'Linda') do |workout|
  workout.interval = '10-9-8-7-6-5-4-3-2-1'
  workout.measurement = time
  workout.exercises.build(movement: deadlift)  do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :weight, value: '1 1/2 body weight')
  end
  workout.exercises.build(movement: bench_press) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :weight, value: 'body weight')
  end
  workout.exercises.build(movement: clean) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :weight, value: '3/4 body weight')
  end
end

cfj.schedules.find_or_create_by(workout: linda, posted_at: '26-05-2018')

# ==============================================================================
# Mary
# As many rounds as possible in 20 minutes
# 5 handstand push-ups
# 10 1-legged squats
# 15 pull-ups
mary = Workout.find_or_create_by(name: 'Mary') do |workout|
  workout.time = 20
  workout.measurement = round
  workout.exercises.build(movement: hspu) do |e|
    e.metrics.build(measurement: :rep, value: 5)
  end
  workout.exercises.build(movement: pistol) do |e|
    e.metrics.build(measurement: :rep, value: 10)
  end
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 15)
  end
end

cfj.schedules.find_or_create_by(workout: mary, posted_at: '12-08-2017')

# ==============================================================================
# Nancy
# 5 rounds for time
# Run 400 meters
# 95-lb. overhead squats, 15 reps
nancy = Workout.find_or_create_by(name: 'Nancy') do |workout|
  workout.rounds = 5
  workout.measurement = time
  workout.exercises.build(movement: run) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :distance, value: 400)
  end
  workout.exercises.build(movement: ohs) do |e|
    e.metrics.build(measurement: :rep, value: 15)
    e.metrics.build(measurement: :weight, value: 95)
  end
end

cfj.schedules.find_or_create_by(workout: nancy, posted_at: '05-06-2018')

# The New Girls WODS

# ==============================================================================
# Annie
# 50-40-30-20-10 reps for time
# Double-unders
# Sit-ups
annie = Workout.find_or_create_by(name: 'Annie') do |workout|
  workout.interval = '50-40-30-20-10'
  workout.measurement = time
  workout.exercises.build(movement: double_under) do |e|
    e.metrics.build(measurement: :rep, value: 1)
  end
  workout.exercises.build(movement: situp) do |e|
    e.metrics.build(measurement: :rep, value: 1)
  end
end

cfj.schedules.find_or_create_by(workout: annie, posted_at: '29-11-2017')

# ==============================================================================
# Eva
# 5 rounds for time
# Run 800 meters
# 2-pood kettlebell swings, 30 reps
# 30 pull-ups
eva = Workout.find_or_create_by(name: 'Eva') do |workout|
  workout.rounds = 5
  workout.measurement = time
  workout.exercises.build(movement: run) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :distance, value: 800)
  end
  workout.exercises.build(movement: kbswing) do |e|
    e.metrics.build(measurement: :rep, value: 30)
    e.metrics.build(measurement: :weight, value: 70)
  end
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 30)
  end
end

cfj.schedules.find_or_create_by(workout: eva, posted_at: '16-01-2018')

# ==============================================================================
# Kelly
# 5 rounds for time
# Run 400 meters
# 30 box jumps, 24-inch box
# 30 wall-ball shots, 20-lb. ball
kelly = Workout.find_or_create_by(name: 'Kelly') do |workout|
  workout.rounds = 5
  workout.measurement = time
  workout.exercises.build(movement: run) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :distance, value: 400)
  end
  workout.exercises.build(movement: box_jump) do |e|
    e.metrics.build(measurement: :rep, value: 30)
  end
  workout.exercises.build(movement: wallball) do |e|
    e.metrics.build(measurement: :rep, value: 30)
  end
end

cfj.schedules.find_or_create_by(workout: kelly, posted_at: '09-02-2018')

# ==============================================================================
# Lynne
# 5 rounds for max reps. There is no time component to this workout,
# although some versions Rx the movements as a couplet.
# Body-weight bench press
# Pull-ups
lynne = Workout.find_or_create_by(name: 'Lynne') do |workout|
  workout.rounds = 5
  workout.measurement = rep
  workout.exercises.build(movement: bench_press) do |e|
    e.metrics.build(measurement: :rep)
    e.metrics.build(measurement: :weight, value: 'body weight')
  end
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 30)
  end
end

cfj.schedules.find_or_create_by(workout: lynne, posted_at: '09-04-2018')

# ==============================================================================
# Nicole
# As many rounds as possible in 20 minutes.
# Note number of pull-ups completed for each round.
# Run 400 meters
# Max-reps pull-ups
nicole = Workout.find_or_create_by(name: 'Nicole') do |workout|
  workout.time = 20
  workout.measurement = round
  workout.exercises.build(movement: run) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :weight, value: 400)
  end
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep)
  end
end

cfj.schedules.find_or_create_by(workout: nicole, posted_at: '30-06-2017')

# ==============================================================================
# Amanda
# 9-7-5 reps for time
# Muscle-ups
# 135-lb. snatches
amanda = Workout.find_or_create_by(name: 'Amanda') do |workout|
  workout.interval = '9-7-5'
  workout.measurement = time
  workout.exercises.build(movement: muscleup) do |e|
    e.metrics.build(measurement: :rep, value: 1)
  end
  workout.exercises.build(movement: snatch) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :weight, value: 135)
  end
end

cfj.schedules.find_or_create_by(workout: amanda, posted_at: '30-03-2017')

# ==============================================================================
# Gwen
# For load
# Clean and jerk 15-12-9 reps
# Touch and go at floor only. Even a re-grip off the floor is a foul. No dumping.
# Use same load for each set. Rest as needed between sets.
gwen = Workout.find_or_create_by(name: 'Gwen') do |workout|
  workout.interval = '15-12-9'
  workout.measurement = weight
  workout.exercises.build(movement: cleanjerk) do |e|
    e.metrics.build(measurement: :rep, value: 1)
      e.metrics.build(measurement: :weight)
  end
end

cfj.schedules.find_or_create_by(workout: gwen, posted_at: '20-11-2017')

# ==============================================================================
# Marguerita
# 50 reps for time
# Burpee/Push-up/Jumping-Jack/Sit-up/Handstand
marguerita = Workout.find_or_create_by(name: 'Marguerita') do |workout|
  workout.rounds = 50
  workout.measurement = time
  workout.exercises.build(movement: burpee) do |e|
    e.metrics.build(measurement: :rep, value: 1)
  end
  workout.exercises.build(movement: pushup) do |e|
    e.metrics.build(measurement: :rep, value: 1)
  end
  workout.exercises.build(movement: jumpingjack) do |e|
    e.metrics.build(measurement: :rep, value: 1)
  end
  workout.exercises.build(movement: situp) do |e|
    e.metrics.build(measurement: :rep, value: 1)
  end
  workout.exercises.build(movement: handstand) do |e|
    e.metrics.build(measurement: :rep, value: 1)
  end
end

cfj.schedules.find_or_create_by(workout: marguerita, posted_at: '15-01-2014')

# ==============================================================================
# Candy
# 5 rounds for time
# 20 pull-ups
# 40 push-ups
# 60 squats
candy = Workout.find_or_create_by(name: 'Candy') do |workout|
  workout.rounds = 5
  workout.measurement = time
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 20)
  end
  workout.exercises.build(movement: pushup) do |e|
    e.metrics.build(measurement: :rep, value: 40)
  end
  workout.exercises.build(movement: airsquat) do |e|
    e.metrics.build(measurement: :rep, value: 60)
  end
end

cfj.schedules.find_or_create_by(workout: candy, posted_at: '11-06-2018')

# ==============================================================================
# Maggie
# 5 rounds for time
# 20 handstand push-ups
# 40 pull-ups
# 60 one-legged squats, alternating legs
maggie = Workout.find_or_create_by(name: 'Maggie') do |workout|
  workout.rounds = 5
  workout.measurement = time
  workout.exercises.build(movement: hspu) do |e|
    e.metrics.build(measurement: :rep, value: 20)
  end
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 40)
  end
  workout.exercises.build(movement: pistol) do |e|
    e.metrics.build(measurement: :rep, value: 60)
  end
end

cfj.schedules.find_or_create_by(workout: maggie, posted_at: '11-06-2018')

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
  workout.rounds = 3
  workout.time = 18
  workout.measurement = rep
  workout.notes = '"Hope" has the same format as Fight Gone Bad. In this'\
                  ' workout you move from each of five stations after a minute.'\
                  ' This is a five-minute round from which a one-minute break is'\
                  ' allowed before repeating. The clock does not reset or stop'\
                  ' between exercises. On call of "rotate," the athlete/s must'\
                  ' move to next station immediately for good score. One point'\
                  ' is given for each rep.'
  workout.exercises.build(movement: burpee) do |e|
    e.metrics.build(measurement: :rep)
  end
  workout.exercises.build(movement: snatch) do |e|
    e.metrics.build(measurement: :rep)
    e.metrics.build(measurement: :weight, value: 75)
  end
  workout.exercises.build(movement: box_jump) do |e|
    e.metrics.build(measurement: :rep)
    e.metrics.build(measurement: :height, value: 24)
  end
  workout.exercises.build(movement: thruster) do |e|
    e.metrics.build(measurement: :rep)
    e.metrics.build(measurement: :weight, value: 75)
  end
  workout.exercises.build(movement: chest2bar) do |e|
    e.metrics.build(measurement: :rep)
  end
  workout.exercises.build(movement: rest) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :time, value: '1:00')
  end
end

cfj.schedules.find_or_create_by(workout: hope, posted_at: '06-07-2013')

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
  workout.exercises.build(movement: hspu) do |e|
    e.metrics.build(measurement: :rep, value: 1)
  end
  workout.exercises.build(movement: ringdip) do |e|
    e.metrics.build(measurement: :rep, value: 1)
  end
  workout.exercises.build(movement: pushup) do |e|
    e.metrics.build(measurement: :rep, value: 1)
  end
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
  workout.exercises.build(movement: run) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :distance, value: 800)
  end
  workout.exercises.build(movement: backext) do |e|
    e.metrics.build(measurement: :rep, value: 50)
  end
  workout.exercises.build(movement: situp) do |e|
    e.metrics.build(measurement: :rep, value: 50)
  end
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
  workout.exercises.build(movement: run, reps: 1, measurement: distance, measurement_value: 1600) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :distance, value: 1600)
  end
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 100)
  end
  workout.exercises.build(movement: pushup) do |e|
    e.metrics.build(measurement: :rep, value: 200)
  end
  workout.exercises.build(movement: airsquat) do |e|
    e.metrics.build(measurement: :rep, value: 300)
  end
  workout.exercises.build(movement: run) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :distance, value: 1600)
  end
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
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 50)
  end
  workout.exercises.build(movement: run) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :distance, value: 400)
  end
  workout.exercises.build(movement: thruster) do |e|
    e.metrics.build(measurement: :rep, value: 21)
    e.metrics.build(measurement: :weight, value: 95)
  end
  workout.exercises.build(movement: run) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :distance, value: 800)
  end
  workout.exercises.build(movement: thruster) do |e|
    e.metrics.build(measurement: :rep, value: 21)
    e.metrics.build(measurement: :weight, value: 95)
  end
  workout.exercises.build(movement: run) do |e|
    e.metrics.build(measurement: :rep, value: 1)
    e.metrics.build(measurement: :distance, value: 400)
  end
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 50)
  end
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
  workout.exercises.build(movement: ohs) do |e|
    e.metrics.build(measurement: :rep, value: 21)
    e.metrics.build(measurement: :weight, value: 95)
  end
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 42)
  end
  workout.exercises.build(movement: ohs) do |e|
    e.metrics.build(measurement: :rep, value: 15)
    e.metrics.build(measurement: :weight, value: 95)
  end
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 30)
  end
  workout.exercises.build(movement: ohs) do |e|
    e.metrics.build(measurement: :rep, value: 9)
    e.metrics.build(measurement: :weight, value: 95)
  end
  workout.exercises.build(movement: pullup) do |e|
    e.metrics.build(measurement: :rep, value: 18)
  end
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
  workout.exercises.build(movement: airsquat) do |e|
    e.metrics.build(measurement: :rep, value: 100)
  end
  workout.exercises.build(movement: muscleup) do |e|
    e.metrics.build(measurement: :rep, value: 5)
  end
  workout.exercises.build(movement: airsquat) do |e|
    e.metrics.build(measurement: :rep, value: 75)
  end
  workout.exercises.build(movement: muscleup) do |e|
    e.metrics.build(measurement: :rep, value: 10)
  end
  workout.exercises.build(movement: airsquat) do |e|
    e.metrics.build(measurement: :rep, value: 50)
  end
  workout.exercises.build(movement: muscleup) do |e|
    e.metrics.build(measurement: :rep, value: 15)
  end
  workout.exercises.build(movement: airsquat) do |e|
    e.metrics.build(measurement: :rep, value: 25)
  end
  workout.exercises.build(movement: muscleup) do |e|
    e.metrics.build(measurement: :rep, value: 20)
  end
end
