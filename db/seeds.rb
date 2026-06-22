# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.find_or_create_by(email: 'admin@wod-tracker.com') do |u|
  u.first_name = "ADMIN"
  u.last_name = "ADMIN"
  u.sex = :male
  u.weight = 0
  u.role = :admin
  u.password = Rails.application.credentials.admin_password
end

# Movements
Movement.find_or_create_by(name: 'AbMat Sit-up')
airsquat = Movement.find_or_create_by(name: 'Air Squat')
backext = Movement.find_or_create_by(name: 'Back Extensions')
Movement.find_or_create_by(name: 'Back Scale')
Movement.find_or_create_by(name: 'Back Squat')
Movement.find_or_create_by(name: 'Bar Muscle-up')
Movement.find_or_create_by(name: 'Barbell Front-rack Lunge')
bench_press = Movement.find_or_create_by(name: 'Bench Press')
bent_over_row = Movement.find_or_create_by(name: 'Bent-over Row')
Movement.find_or_create_by(name: 'Body Blaster')
box_jump = Movement.find_or_create_by(name: 'Box Jump')
Movement.find_or_create_by(name: 'Box Step-up')
burpee = Movement.find_or_create_by(name: 'Burpee')
Movement.find_or_create_by(name: 'Burpee Box Jump')
Movement.find_or_create_by(name: 'Burpee Box Jump-over')
Movement.find_or_create_by(name: 'Butterfly Pull-up')
chest2bar = Movement.find_or_create_by(name: 'Chest-to-bar Pull-up')
Movement.find_or_create_by(name: 'Chest-to-wall Handstand Push-up')
Movement.find_or_create_by(name: 'Clean')
cleanjerk = Movement.find_or_create_by(name: 'Clean and Jerk')
Movement.find_or_create_by(name: 'Clean and Push Jerk')
clean = Movement.find_or_create_by(name: 'Clean Squat')
deadlift = Movement.find_or_create_by(name: 'Deadlift')
Movement.find_or_create_by(name: 'Dip')
double_under = Movement.find_or_create_by(name: 'Double-under')
Movement.find_or_create_by(name: 'Dumbbell Bench Press')
Movement.find_or_create_by(name: 'Dumbbell Box Step-up')
Movement.find_or_create_by(name: 'Dumbbell Clean')
Movement.find_or_create_by(name: 'Dumbbell Deadlift')
Movement.find_or_create_by(name: 'Dumbbell Farmers Carry')
Movement.find_or_create_by(name: 'Dumbbell Front Squat')
Movement.find_or_create_by(name: 'Dumbbell Front-rack Lunge')
Movement.find_or_create_by(name: 'Dumbbell Hang Clean')
Movement.find_or_create_by(name: 'Dumbbell Hang Clean and Jerk')
Movement.find_or_create_by(name: 'Dumbbell Hang Power Clean')
Movement.find_or_create_by(name: 'Dumbbell Overhead Squat')
Movement.find_or_create_by(name: 'Dumbbell Overhead Walking Lunge')
Movement.find_or_create_by(name: 'Dumbbell Power Clean')
Movement.find_or_create_by(name: 'Dumbbell Power Snatch')
Movement.find_or_create_by(name: 'Dumbbell Push Jerk')
Movement.find_or_create_by(name: 'Dumbbell Push Press')
Movement.find_or_create_by(name: 'Dumbbell Squat Snatch')
Movement.find_or_create_by(name: 'Dumbbell Thruster')
Movement.find_or_create_by(name: 'Dumbbell Turkish Get-up')
Movement.find_or_create_by(name: 'Forward Roll From Support')
Movement.find_or_create_by(name: 'Freestanding Handstand Push-up')
freestanding_shoulder_tap = Movement.find_or_create_by(name: 'Freestanding Shoulder Tap')
Movement.find_or_create_by(name: 'Front Scale')
Movement.find_or_create_by(name: 'Front Squat')
Movement.find_or_create_by(name: 'GHD Back Extension')
Movement.find_or_create_by(name: 'GHD Hip and Back Extension')
Movement.find_or_create_by(name: 'GHD Hip Extension')
Movement.find_or_create_by(name: 'GHD Sit-up')
Movement.find_or_create_by(name: 'Glide Kip')
Movement.find_or_create_by(name: 'Good Morning')
handstand = Movement.find_or_create_by(name: 'Handstand')
Movement.find_or_create_by(name: 'Handstand Pirouette')
hspu = Movement.find_or_create_by(name: 'Handstand Push-up')
Movement.find_or_create_by(name: 'Handstand Walk')
Movement.find_or_create_by(name: 'Hang Clean')
Movement.find_or_create_by(name: 'Hang Clean and Push Jerk')
Movement.find_or_create_by(name: 'Hang Power Clean')
Movement.find_or_create_by(name: 'Hang Power Snatch')
Movement.find_or_create_by(name: 'Hang Snatch')
Movement.find_or_create_by(name: 'Hanging L-sit')
Movement.find_or_create_by(name: 'Hip Extensions')
Movement.find_or_create_by(name: 'Inverted Burpee')
jumpingjack = Movement.find_or_create_by(name: 'Jumping Jack')
jumping_lunge = Movement.find_or_create_by(name: 'Jumping Lunge')
Movement.find_or_create_by(name: 'Kettlebell Snatch')
Movement.find_or_create_by(name: 'Kettlebell Sumo Hi Pull')
kbswing = Movement.find_or_create_by(name: 'Kettlebell Swing')
l_pullup = Movement.find_or_create_by(name: 'L Pull-up')
Movement.find_or_create_by(name: 'L Sit Hold on Matador')
Movement.find_or_create_by(name: 'L-sit')
Movement.find_or_create_by(name: 'L-sit on Rings')
Movement.find_or_create_by(name: 'L-sit Rope Climb')
Movement.find_or_create_by(name: 'L-sit to Shoulder Stand')
Movement.find_or_create_by(name: 'Lateral Over Barbell Burpee')
Movement.find_or_create_by(name: 'Legless Rope Climb')
Movement.find_or_create_by(name: 'Lunge')
Movement.find_or_create_by(name: 'Lunge with plate overhead')
Movement.find_or_create_by(name: 'Medicine-ball Clean')
Movement.find_or_create_by(name: 'Modified Rope Climb')
Movement.find_or_create_by(name: 'Muscle Snatch')
muscleup = Movement.find_or_create_by(name: 'Muscle-up')
Movement.find_or_create_by(name: 'Over the bar Burpee')
Movement.find_or_create_by(name: 'Over the medball Burpee')
Movement.find_or_create_by(name: 'Overhead Dumbbell Lunge')
ohs = Movement.find_or_create_by(name: 'Overhead Squat')
Movement.find_or_create_by(name: 'Power Clean')
Movement.find_or_create_by(name: 'Power Clean and Split Jerk')
Movement.find_or_create_by(name: 'Power Snatch')
Movement.find_or_create_by(name: 'Pull-over')
pullup = Movement.find_or_create_by(name: 'Pull-up')
Movement.find_or_create_by(name: 'Push Jerk')
push_press = Movement.find_or_create_by(name: 'Push Press')
pushup = Movement.find_or_create_by(name: 'Push-up')
deficit_pushup = Movement.find_or_create_by(name: 'Deficit Push-up')
Movement.find_or_create_by(name: 'Renegade Row')
rest = Movement.find_or_create_by(name: 'Rest')
ringdip = Movement.find_or_create_by(name: 'Ring Dip')
Movement.find_or_create_by(name: 'Ring Muscle-up')
Movement.find_or_create_by(name: 'Ring Push-up')
Movement.find_or_create_by(name: 'Ring Row')
Movement.find_or_create_by(name: 'Rope Climb')
row = Movement.find_or_create_by(name: 'Row')
run = Movement.find_or_create_by(name: 'Run')
Movement.find_or_create_by(name: 'Shoot-through')
Movement.find_or_create_by(name: 'Shoulder Press')
Movement.find_or_create_by(name: 'Shoulder to Overhead')
pistol = Movement.find_or_create_by(name: 'Single-leg Squat (Pistol)')
Movement.find_or_create_by(name: 'Single-under')
situp = Movement.find_or_create_by(name: 'Sit-up')
skin_the_cat = Movement.find_or_create_by(name: 'Skin the Cat')
Movement.find_or_create_by(name: 'Slam Ball')
sled_drag = Movement.find_or_create_by(name: 'Sled Drag')
Movement.find_or_create_by(name: 'Sled Pull')
snatch = Movement.find_or_create_by(name: 'Snatch')
Movement.find_or_create_by(name: 'Snatch Balance')
Movement.find_or_create_by(name: 'Sots Press')
Movement.find_or_create_by(name: 'Split Clean')
Movement.find_or_create_by(name: 'Split Jerk')
Movement.find_or_create_by(name: 'Split Snatch')
Movement.find_or_create_by(name: 'Straddle Press to Handstand')
Movement.find_or_create_by(name: 'Strict Bar Muscle-up')
Movement.find_or_create_by(name: 'Strict Chest-to-bar Pull-up')
Movement.find_or_create_by(name: 'Strict Handstand Push-up')
Movement.find_or_create_by(name: 'Strict Knees-to-elbows')
Movement.find_or_create_by(name: 'Strict Muscle-up')
Movement.find_or_create_by(name: 'Strict Pull-up')
Movement.find_or_create_by(name: 'Strict Toes-to-bar')
Movement.find_or_create_by(name: 'Strict Toes-to-rings')
Movement.find_or_create_by(name: 'Sumo Deadlift')
sumo_deadlift_hight_pull = Movement.find_or_create_by(name: 'Sumo Deadlift High Pull')
Movement.find_or_create_by(name: 'Swim')
Movement.find_or_create_by(name: 'Swing to Backward Roll to Support')
Movement.find_or_create_by(name: 'Tempo Jerk')
thruster = Movement.find_or_create_by(name: 'Thruster')
Movement.find_or_create_by(name: 'Toes to Bar')
Movement.find_or_create_by(name: 'Toes to Bar + Pull-up')
Movement.find_or_create_by(name: 'Tuck-up')
Movement.find_or_create_by(name: 'V-up')
Movement.find_or_create_by(name: 'Walking Lunge')
Movement.find_or_create_by(name: 'Wall Walk')
wallball = Movement.find_or_create_by(name: 'Wall-ball Shot')
Movement.find_or_create_by(name: 'Windshield Wiper')
Movement.find_or_create_by(name: 'Zercher Squat')

# Programs
cfj = Program.find_or_create_by(name: 'Crossfit Journal')

# 260622
# On a 20-minute clock for total reps:
# 0:00-5:00:
# 200-meter run
# Max freestanding shoulder taps
#
# 5:00-10:00:
# 200-meter run
# Max skin-the-cats
#
# 10:00-15:00:
# 200-meter run
# Max L pull-ups
#
# 15:00-20:00:
# 200-meter run
# Max deficit push-ups
#
# Female 2-inch deficit
# Male 4-inch deficit
crossfit_260622 = Workout.find_or_create_by(name: 'CF-260622') do |workout|
  workout.time = 20
  workout.score_type = :rep
  workout.notes = 'Each 5-minute window begins with a 200-meter run, followed by max reps of the gymnastics movement. '\
                  'Post total reps to comments. '\
                  'Intermediate option: use wall-facing handstand shoulder taps, skin-the-cats, strict pull-ups, and push-ups. '\
                  'Beginner option: use 100-meter runs with plank shoulder taps, ring hanging leg raises, foot-assisted pull-ups, and hand-elevated push-ups. '\
                  'Source: https://www.crossfit.com/260622'

  first_window = workout.segments.build(name: '0:00-5:00', time_seconds: 300, position: 1)
  workout.exercises.build(movement: run, segment: first_window, position: 1,
                          reps: 1, distance: 200, distance_unit: :meter)
  workout.exercises.build(movement: freestanding_shoulder_tap, segment: first_window,
                          position: 2, reps: 0)

  second_window = workout.segments.build(name: '5:00-10:00', time_seconds: 300, position: 2)
  workout.exercises.build(movement: run, segment: second_window, position: 1,
                          reps: 1, distance: 200, distance_unit: :meter)
  workout.exercises.build(movement: skin_the_cat, segment: second_window, position: 2, reps: 0)

  third_window = workout.segments.build(name: '10:00-15:00', time_seconds: 300, position: 3)
  workout.exercises.build(movement: run, segment: third_window, position: 1,
                          reps: 1, distance: 200, distance_unit: :meter)
  workout.exercises.build(movement: l_pullup, segment: third_window, position: 2, reps: 0)

  fourth_window = workout.segments.build(name: '15:00-20:00', time_seconds: 300, position: 4)
  workout.exercises.build(movement: run, segment: fourth_window, position: 1,
                          reps: 1, distance: 200, distance_unit: :meter)
  workout.exercises.build(movement: deficit_pushup, segment: fourth_window, position: 2,
                          reps: 0, female_distance: 2, male_distance: 4, distance_unit: :inch)
end

cfj.schedules.find_or_initialize_by(workout: crossfit_260622).update(posted_at: Date.new(2026, 6, 22))

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
  workout.rounds = 3
  workout.time = 18
  workout.notes = 'In this workout you move from each of 5 stations after a minute.'\
          ' This is a 5-minute round after which a 1-minute break is allowed before repeating.'\
          ' The clock does not reset or stop between exercises.'\
          ' On the call of "rotate," the athlete(s) must move to the next station immediately for a good score.'\
          ' One point is given for each rep, except on the rower where each calorie is 1 point.'
  workout.exercises.build(movement: wallball, position: 1, reps: 0, duration_seconds: 60, female_load: 14, male_load: 20, load_unit: :lb, female_distance: 9, male_distance: 10, distance_unit: :foot)
  workout.exercises.build(movement: sumo_deadlift_hight_pull, position: 2, reps: 0, duration_seconds: 60, female_load: 55, male_load: 75, load_unit: :lb)
  workout.exercises.build(movement: box_jump, position: 3, reps: 0, duration_seconds: 60, distance: 20, distance_unit: :inch)
  workout.exercises.build(movement: push_press, position: 4, reps: 0, duration_seconds: 60, female_load: 55, male_load: 75, load_unit: :lb)
  workout.exercises.build(movement: row, position: 5, reps: 1, calories: 0, duration_seconds: 60)
  workout.exercises.build(movement: rest, position: 6, reps: 1, duration_seconds: 60)
end

cfj.schedules.find_or_initialize_by(workout: fight_gone_bad).update(posted_at: '01-02-2018')

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
  workout.score_type = :time
  workout.exercises.build(movement: pullup, position: 1, reps: 100)
  workout.exercises.build(movement: pushup, position: 2, reps: 100)
  workout.exercises.build(movement: situp, position: 3, reps: 100)
  workout.exercises.build(movement: airsquat, position: 4, reps: 100)
end

cfj.schedules.find_or_initialize_by(workout: angie).update(posted_at: '30-01-2018')

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
  workout.score_type = :time
  workout.exercises.build(movement: pullup, position: 1, reps: 20)
  workout.exercises.build(movement: pushup, position: 2, reps: 30)
  workout.exercises.build(movement: situp, position: 3, reps: 40)
  workout.exercises.build(movement: airsquat, position: 4, reps: 50)
  workout.exercises.build(movement: rest, position: 5, reps: 1, duration_seconds: 180)
end

cfj.schedules.find_or_initialize_by(workout: barbara).update(posted_at: '29-01-2018')

# ==============================================================================
# Chelsea
# Every minute on the minute for 30 minutes
# 5 pull-ups
# 10 push-ups
# 15 squats
chelsea = Workout.find_or_create_by(name: 'Chelsea') do |workout|
  workout.rounds = 30
  workout.time = 30
  workout.score_type = :rep
  workout.exercises.build(movement: pullup, position: 1, reps: 5)
  workout.exercises.build(movement: pushup, position: 2, reps: 10)
  workout.exercises.build(movement: airsquat, position: 3, reps: 15)
end

cfj.schedules.find_or_initialize_by(workout: chelsea).update(posted_at: '28-01-2018')

# ==============================================================================
# Cindy
# As many rounds as possible in 20 minutes
# 5 pull-ups
# 10 push-ups
# 15 squats
cindy = Workout.find_or_create_by(name: 'Cindy') do |workout|
  workout.time = 20
  workout.score_type = :rep
  workout.exercises.build(movement: pullup, position: 1, reps: 5)
  workout.exercises.build(movement: pushup, position: 2, reps: 10)
  workout.exercises.build(movement: airsquat, position: 3, reps: 15)
end

cfj.schedules.find_or_initialize_by(workout: cindy).update(posted_at: '27-01-2018')

# ==============================================================================
# Diane
# 21-15-9 reps for time
# 225-lb. deadlifts
# Handstand push-ups
diane = Workout.find_or_create_by(name: 'Diane') do |workout|
  workout.interval = '21-15-9'
  workout.score_type = :time
  workout.exercises.build(movement: deadlift, position: 1, reps: 1, female_load: 155, male_load: 225, load_unit: :lb)
  workout.exercises.build(movement: hspu, position: 2, reps: 1)
end

cfj.schedules.find_or_initialize_by(workout: diane).update(posted_at: '26-01-2018')

# ==============================================================================
# Elizabeth
# 21-15-9 reps for time
# 135-lb. cleans
# Ring dips
elizabeth = Workout.find_or_create_by(name: 'Elizabeth') do |workout|
  workout.interval = '21-15-9'
  workout.score_type = :time
  workout.exercises.build(movement: clean, position: 1, reps: 1, female_load: 95, male_load: 135, load_unit: :lb)
  workout.exercises.build(movement: ringdip, position: 2, reps: 1)
end

cfj.schedules.find_or_initialize_by(workout: elizabeth).update(posted_at: '25-01-2018')

# ==============================================================================
# Fran
# 21-15-9 reps for time
# 95-lb. thrusters
# Pull-ups
fran = Workout.find_or_create_by(name: 'Fran') do |workout|
  workout.interval = '21-15-9'
  workout.score_type = :time
  workout.exercises.build(movement: thruster, position: 1, reps: 1, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: pullup, position: 2, reps: 1)
end

cfj.schedules.find_or_initialize_by(workout: fran).update(posted_at: '24-01-2018')

# ==============================================================================
# Grace
# 30 reps for time
# 135-lb. clean and jerks
grace = Workout.find_or_create_by(name: 'Grace') do |workout|
  workout.rounds = 1
  workout.score_type = :time
  workout.exercises.build(movement: cleanjerk, position: 1, reps: 30, female_load: 95, male_load: 135, load_unit: :lb)
end

 cfj.schedules.find_or_initialize_by(workout: grace).update(posted_at: '23-01-2018')

# ==============================================================================
# Helen
# 3 rounds for time
# Run 400 meters
# 1.5-pood kettlebell swings, 21 reps
# 12 pull-ups
helen = Workout.find_or_create_by(name: 'Helen') do |workout|
  workout.rounds = 3
  workout.score_type = :time
  workout.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  workout.exercises.build(movement: kbswing, position: 2, reps: 21, female_load: 35, male_load: 53, load_unit: :lb)
  workout.exercises.build(movement: pullup, position: 3, reps: 12)
end

cfj.schedules.find_or_initialize_by(workout: helen).update(posted_at: '22-01-2018')

# ==============================================================================
# Isabel
# 30 reps for time
# 135-lb. snatches
isabel = Workout.find_or_create_by(name: 'Isabel') do |workout|
  workout.rounds = 1
  workout.score_type = :time
  workout.exercises.build(movement: snatch, position: 1, reps: 30, female_load: 95, male_load: 135, load_unit: :lb)
end

cfj.schedules.find_or_initialize_by(workout: isabel).update(posted_at: '21-01-2018')

# ==============================================================================
# Jackie
# For time
# Row 1,000 meters
# 45-lb. thrusters, 50 reps
# 30 pull-ups
jackie = Workout.find_or_create_by(name: 'Jackie') do |workout|
  workout.rounds = 1
  workout.score_type = :time
  workout.exercises.build(movement: row, position: 1, reps: 1, distance: 1000, distance_unit: :meter)
  workout.exercises.build(movement: thruster, position: 2, reps: 50, female_load: 35, male_load: 45, load_unit: :lb)
  workout.exercises.build(movement: pullup, position: 3, reps: 30)
end

cfj.schedules.find_or_initialize_by(workout: jackie).update(posted_at: '20-01-2018')

# ==============================================================================
# Karen
# For time
# 150 wall-ball shots, 20-lb. ball
karen = Workout.find_or_create_by(name: 'Karen') do |workout|
  workout.rounds = 1
  workout.score_type = :time
  workout.exercises.build(movement: wallball, position: 1, reps: 150, female_load: 14, male_load: 20, load_unit: :lb, female_distance: 9, male_distance: 10, distance_unit: :foot)
end

cfj.schedules.find_or_initialize_by(workout: karen).update(posted_at: '19-01-2018')

# ==============================================================================
# Linda (a.k.a. 3 Bars of Death)
# 10-9-8-7-6-5-4-3-2-1 reps for time
# 1 1/2 body-weight deadlifts
# Body-weight bench presses
# 3/4 body-weight cleans
linda = Workout.find_or_create_by(name: 'Linda') do |workout|
  workout.interval = '10-9-8-7-6-5-4-3-2-1'
  workout.score_type = :time
  workout.exercises.build(movement: deadlift, position: 1, reps: 1, notes: '1 1/2 body weight')
  workout.exercises.build(movement: bench_press, position: 2, reps: 1, notes: 'body weight')
  workout.exercises.build(movement: clean, position: 3, reps: 1, notes: '3/4 body weight')
end

cfj.schedules.find_or_initialize_by(workout: linda).update(posted_at: '18-01-2018')

# ==============================================================================
# Mary
# As many rounds as possible in 20 minutes
# 5 handstand push-ups
# 10 1-legged squats
# 15 pull-ups
mary = Workout.find_or_create_by(name: 'Mary') do |workout|
  workout.time = 20
  workout.score_type = :rep
  workout.exercises.build(movement: hspu, position: 1, reps: 5)
  workout.exercises.build(movement: pistol, position: 2, reps: 10)
  workout.exercises.build(movement: pullup, position: 3, reps: 15)
end

cfj.schedules.find_or_initialize_by(workout: mary).update(posted_at: '17-01-2018')

# ==============================================================================
# Nancy
# 5 rounds for time
# Run 400 meters
# 95-lb. overhead squats, 15 reps
nancy = Workout.find_or_create_by(name: 'Nancy') do |workout|
  workout.rounds = 5
  workout.score_type = :time
  workout.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  workout.exercises.build(movement: ohs, position: 2, reps: 15, female_load: 65, male_load: 95, load_unit: :lb)
end

cfj.schedules.find_or_initialize_by(workout: nancy).update(posted_at: '16-01-2018')

# The New Girls WODS

# ==============================================================================
# Annie
# 50-40-30-20-10 reps for time
# Double-unders
# Sit-ups
annie = Workout.find_or_create_by(name: 'Annie') do |workout|
  workout.interval = '50-40-30-20-10'
  workout.score_type = :time
  workout.exercises.build(movement: double_under, position: 1, reps: 1)
  workout.exercises.build(movement: situp, position: 2, reps: 1)
end

cfj.schedules.find_or_initialize_by(workout: annie).update(posted_at: '15-01-2018')

# ==============================================================================
# Eva
# 5 rounds for time
# Run 800 meters
# 2-pood kettlebell swings, 30 reps
# 30 pull-ups
eva = Workout.find_or_create_by(name: 'Eva') do |workout|
  workout.rounds = 5
  workout.score_type = :time
  workout.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  workout.exercises.build(movement: kbswing, position: 2, reps: 30, female_load: 53, male_load: 70, load_unit: :lb)
  workout.exercises.build(movement: pullup, position: 3, reps: 30)
end

cfj.schedules.find_or_initialize_by(workout: eva).update(posted_at: '14-01-2018')

# ==============================================================================
# Kelly
# 5 rounds for time
# Run 400 meters
# 30 box jumps, 24-inch box
# 30 wall-ball shots, 20-lb. ball
kelly = Workout.find_or_create_by(name: 'Kelly') do |workout|
  workout.rounds = 5
  workout.score_type = :time
  workout.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  workout.exercises.build(movement: box_jump, position: 2, reps: 30, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: wallball, position: 3, reps: 30, female_load: 14, male_load: 20, load_unit: :lb, female_distance: 9, male_distance: 10, distance_unit: :foot)
end

cfj.schedules.find_or_initialize_by(workout: kelly).update(posted_at: '13-01-2018')

# ==============================================================================
# Lynne
# 5 rounds for max reps. There is no time component to this workout,
# although some versions Rx the movements as a couplet.
# Body-weight bench press
# Pull-ups
lynne = Workout.find_or_create_by(name: 'Lynne') do |workout|
  workout.rounds = 5
  workout.score_type = :rep
  workout.exercises.build(movement: bench_press, position: 1, reps: 0, notes: 'body weight')
  workout.exercises.build(movement: pullup, position: 2, reps: 30)
end

cfj.schedules.find_or_initialize_by(workout: lynne).update(posted_at: '12-01-2018')

# ==============================================================================
# Nicole
# As many rounds as possible in 20 minutes.
# Note number of pull-ups completed for each round.
# Run 400 meters
# Max-reps pull-ups
nicole = Workout.find_or_create_by(name: 'Nicole') do |workout|
  workout.time = 20
  workout.score_type = :round
  workout.exercises.build(movement: run, position: 1, reps: 1, distance: 400, distance_unit: :meter)
  workout.exercises.build(movement: pullup, position: 2, reps: 0)
end

cfj.schedules.find_or_initialize_by(workout: nicole).update(posted_at: '11-01-2018')

# ==============================================================================
# Amanda
# 9-7-5 reps for time
# Muscle-ups
# 135-lb. snatches
amanda = Workout.find_or_create_by(name: 'Amanda') do |workout|
  workout.interval = '9-7-5'
  workout.score_type = :time
  workout.exercises.build(movement: muscleup, position: 1, reps: 1)
  workout.exercises.build(movement: snatch, position: 2, reps: 1, female_load: 95, male_load: 135, load_unit: :lb)
end

cfj.schedules.find_or_initialize_by(workout: amanda).update(posted_at: '10-01-2018')

# ==============================================================================
# Gwen
# For load
# Clean and jerk 15-12-9 reps
# Touch and go at floor only. Even a re-grip off the floor is a foul. No dumping.
# Use same load for each set. Rest as needed between sets.
gwen = Workout.find_or_create_by(name: 'Gwen') do |workout|
  workout.interval = '15-12-9'
  workout.score_type = :weight
  workout.exercises.build(movement: cleanjerk, position: 1, reps: 1, load_unit: :lb)
end

cfj.schedules.find_or_initialize_by(workout: gwen).update(posted_at: '09-01-2018')

# ==============================================================================
# Marguerita
# 50 reps for time
# Burpee/Push-up/Jumping-Jack/Sit-up/Handstand
marguerita = Workout.find_or_create_by(name: 'Marguerita') do |workout|
  workout.rounds = 50
  workout.score_type = :time
  workout.exercises.build(movement: burpee, position: 1, reps: 1)
  workout.exercises.build(movement: pushup, position: 2, reps: 1)
  workout.exercises.build(movement: jumpingjack, position: 3, reps: 1)
  workout.exercises.build(movement: situp, position: 4, reps: 1)
  workout.exercises.build(movement: handstand, position: 5, reps: 1)
end

cfj.schedules.find_or_initialize_by(workout: marguerita).update(posted_at: '08-01-2018')

# ==============================================================================
# Candy
# 5 rounds for time
# 20 pull-ups
# 40 push-ups
# 60 squats
candy = Workout.find_or_create_by(name: 'Candy') do |workout|
  workout.rounds = 5
  workout.score_type = :time
  workout.exercises.build(movement: pullup, position: 1, reps: 20)
  workout.exercises.build(movement: pushup, position: 2, reps: 40)
  workout.exercises.build(movement: airsquat, position: 3, reps: 60)
end

cfj.schedules.find_or_initialize_by(workout: candy).update(posted_at: '07-01-2018')

# ==============================================================================
# Maggie
# 5 rounds for time
# 20 handstand push-ups
# 40 pull-ups
# 60 one-legged squats, alternating legs
maggie = Workout.find_or_create_by(name: 'Maggie') do |workout|
  workout.rounds = 5
  workout.score_type = :time
  workout.exercises.build(movement: hspu, position: 1, reps: 20)
  workout.exercises.build(movement: pullup, position: 2, reps: 40)
  workout.exercises.build(movement: pistol, position: 3, reps: 60)
end

cfj.schedules.find_or_initialize_by(workout: maggie).update(posted_at: '06-01-2018')

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
  workout.score_type = :rep
  workout.notes = '"Hope" has the same format as Fight Gone Bad. In this'\
                  ' workout you move from each of five stations after a minute.'\
                  ' This is a five-minute round from which a one-minute break is'\
                  ' allowed before repeating. The clock does not reset or stop'\
                  ' between exercises. On call of "rotate," the athlete/s must'\
                  ' move to next station immediately for good score. One point'\
                  ' is given for each rep.'
  workout.exercises.build(movement: burpee, position: 1, reps: 0)
  workout.exercises.build(movement: snatch, position: 2, reps: 0, female_load: 55, male_load: 75, load_unit: :lb)
  workout.exercises.build(movement: box_jump, position: 3, reps: 0, female_distance: 20, male_distance: 24, distance_unit: :inch)
  workout.exercises.build(movement: thruster, position: 4, reps: 0, female_load: 55, male_load: 75, load_unit: :lb)
  workout.exercises.build(movement: chest2bar, position: 5, reps: 0)
  workout.exercises.build(movement: rest, position: 6, reps: 1, duration_seconds: 60)
end

cfj.schedules.find_or_initialize_by(workout: hope).update(posted_at: '05-01-2018')

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
  workout.exercises.build(movement: hspu, position: 1, reps: 1)
  workout.exercises.build(movement: ringdip, position: 2, reps: 1)
  workout.exercises.build(movement: pushup, position: 3, reps: 1)
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
  workout.exercises.build(movement: backext, position: 2, reps: 50)
  workout.exercises.build(movement: situp, position: 3, reps: 50)
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
  workout.exercises.build(movement: pullup, position: 2, reps: 100)
  workout.exercises.build(movement: pushup, position: 3, reps: 200)
  workout.exercises.build(movement: airsquat, position: 4, reps: 300)
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
  workout.exercises.build(movement: pullup, position: 1, reps: 50)
  workout.exercises.build(movement: run, position: 2, reps: 1, distance: 400, distance_unit: :meter)
  workout.exercises.build(movement: thruster, position: 3, reps: 21, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: run, position: 4, reps: 1, distance: 800, distance_unit: :meter)
  workout.exercises.build(movement: thruster, position: 5, reps: 21, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: run, position: 6, reps: 1, distance: 400, distance_unit: :meter)
  workout.exercises.build(movement: pullup, position: 7, reps: 50)
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
  workout.exercises.build(movement: ohs, position: 1, reps: 21, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: pullup, position: 2, reps: 42)
  workout.exercises.build(movement: ohs, position: 3, reps: 15, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: pullup, position: 4, reps: 30)
  workout.exercises.build(movement: ohs, position: 5, reps: 9, female_load: 65, male_load: 95, load_unit: :lb)
  workout.exercises.build(movement: pullup, position: 6, reps: 18)
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
  workout.exercises.build(movement: airsquat, position: 1, reps: 100)
  workout.exercises.build(movement: muscleup, position: 2, reps: 5)
  workout.exercises.build(movement: airsquat, position: 3, reps: 75)
  workout.exercises.build(movement: muscleup, position: 4, reps: 10)
  workout.exercises.build(movement: airsquat, position: 5, reps: 50)
  workout.exercises.build(movement: muscleup, position: 6, reps: 15)
  workout.exercises.build(movement: airsquat, position: 7, reps: 25)
  workout.exercises.build(movement: muscleup, position: 8, reps: 20)
end

# Example WODS
#
# ==============================================================================
# https://www.crossfit.com/workout/2018/12/02#/comments
# For time:
# Run 800 meters
# Then, 10 rounds of the couplet:
#    10 handstand push-ups
#    10 single-leg squats
# Then, run 800 meters
segmented = Workout.find_or_create_by!(name: 'CFJ-181202') do |workout|
  workout.score_type = :time
  workout.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  seg = workout.segments.build(rounds: 10, position: 2)
  workout.exercises.build(movement: hspu, segment: seg, position: 1, reps: 10)
  workout.exercises.build(movement: pistol, segment: seg, position: 2, reps: 10)
  workout.exercises.build(movement: run, position: 4, reps: 1, distance: 800, distance_unit: :meter)
end

cfj.schedules.find_or_initialize_by(workout: segmented).update(posted_at: '02-12-2018')

# ==============================================================================
# https://www.crossfit.com/workout/2018/12/26#/comments
# Tabata handstand push-ups
# Rest 1 minute
# Tabata single-leg squats
# Rest 1 minute
# Tabata push-ups
# Rest 1 minute
# Tabata jumping lunges
#
# The Tabata interval is 20 seconds of work followed by 10 seconds of rest for
# 8 intervals. Post reps for each exercise completed
tabata = Workout.find_or_create_by!(name: 'CFJ-181226') do |workout|
  workout.score_type = :rep
  tab1 = workout.segments.build(rounds: 8, position: 1)
  workout.exercises.build(movement: hspu, segment: tab1, position: 1, duration_seconds: 20)
  workout.exercises.build(movement: rest, segment: tab1, position: 2, duration_seconds: 10)

  workout.exercises.build(movement: rest, position: 2, duration_seconds: 60)

  tab2 = workout.segments.build(rounds: 8, position: 3)
  workout.exercises.build(movement: pistol, segment: tab2, position: 1, duration_seconds: 20)
  workout.exercises.build(movement: rest, segment: tab2, position: 2, duration_seconds: 10)

  workout.exercises.build(movement: rest, position: 4, duration_seconds: 60)

  tab3 = workout.segments.build(rounds: 8, position: 5)
  workout.exercises.build(movement: pushup, segment: tab3, position: 1, duration_seconds: 20)
  workout.exercises.build(movement: rest, segment: tab3, position: 2, duration_seconds: 10)

  workout.exercises.build(movement: rest, position: 6, duration_seconds: 60)

  tab4 = workout.segments.build(rounds: 8, position: 7)
  workout.exercises.build(movement: jumping_lunge, segment: tab4, position: 1, duration_seconds: 20)
  workout.exercises.build(movement: rest, segment: tab4, position: 2, duration_seconds: 10)
end

cfj.schedules.find_or_initialize_by(workout: tabata).update(posted_at: '26-12-2018')

# ==============================================================================
# https://www.crossfit.com/260620
# For time:
# 1,600-meter sled drag while carrying a barbell in the front rack
# Every time you stop, complete 15 bent-over rows before resuming.
#
# ♀ 95-lb. barbell and 95-lb. sled / ♂ 135-lb. barbell and 135-lb. sled
#
# The sled attaches at the waist. Take strategic breaks to hold a steady pace
# rather than dragging until forced to stop. The bent-over rows are a penalty
# triggered by stopping, so they live in a segment named for that trigger; the
# number performed depends on how often the athlete breaks and is logged as the
# total reps actually completed.
sled_drag_carry = Workout.find_or_create_by!(name: 'CFJ-260620') do |workout|
  workout.rounds = 1
  workout.score_type = :time
  workout.notes = 'Drag the sled 1,600 meters while carrying a barbell in the'\
                  ' front rack; the barbell and sled are loaded the same and the'\
                  ' sled attaches at the waist. Every time you stop, complete 15'\
                  ' bent-over rows before resuming. Take strategic breaks to hold'\
                  ' a steady pace rather than dragging until forced to stop.'
  workout.exercises.build(movement: sled_drag, position: 1, reps: 1, distance: 1600, distance_unit: :meter,
                          female_load: 95, male_load: 135, load_unit: :lb,
                          notes: 'Carry a barbell in the front rack while dragging the waist sled;'\
                                 ' barbell and sled loaded the same.')
  penalty = workout.segments.build(position: 2, name: 'Every time you stop')
  workout.exercises.build(movement: bent_over_row, segment: penalty, position: 1, reps: 15,
                          female_load: 95, male_load: 135, load_unit: :lb,
                          notes: 'Performed with the barbell. Log the total reps actually completed.')
end

cfj.schedules.find_or_initialize_by(workout: sled_drag_carry).update(posted_at: '20-06-2026')
