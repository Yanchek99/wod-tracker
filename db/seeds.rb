# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
admin = User.find_or_create_by(email: 'admin@wod-tracker.com') do |u|
  u.first_name = 'ADMIN'
  u.last_name = 'ADMIN'
  u.sex = :male
  u.weight = 0
  u.role = :admin
  u.password = Rails.application.credentials.admin_password
end

# Movements
def seed_movement(name, **taxonomy)
  Movement.find_or_initialize_by(name:).tap do |movement|
    movement.assign_attributes(taxonomy)
    movement.save!
  end
end

abmat_sit_up = seed_movement('AbMat Sit-up', family: :gymnastics, pattern: :rotation, skill_level: :basic)
air_squat = seed_movement('Air Squat', family: :gymnastics, pattern: :squat, skill_level: :basic)
back_extensions = seed_movement('Back Extensions', family: :gymnastics, pattern: :hinge, skill_level: :basic)
back_scale = seed_movement('Back Scale', family: :gymnastics, pattern: :hinge, skill_level: :intermediate)
back_squat = seed_movement('Back Squat', family: :weightlifting, pattern: :squat, equipment: :barbell,
                                         skill_level: :basic)
bar_muscle_up = seed_movement('Bar Muscle-up', family: :gymnastics, pattern: :pull, equipment: :pull_up_bar,
                                               skill_level: :advanced)
barbell_front_rack_lunge = seed_movement('Barbell Front-rack Lunge', family: :weightlifting, pattern: :lunge,
                                                                     equipment: :barbell, skill_level: :intermediate)
bench_press = seed_movement('Bench Press', family: :weightlifting, pattern: :press, equipment: :barbell,
                                           skill_level: :basic)
bent_over_row = seed_movement('Bent-over Row', family: :weightlifting, pattern: :pull, equipment: :barbell,
                                               skill_level: :basic)
body_blaster = seed_movement('Body Blaster', family: :gymnastics, pattern: :mixed, skill_level: :intermediate)
box_jump = seed_movement('Box Jump', family: :gymnastics, pattern: :jump, equipment: :box, skill_level: :basic)
box_step_up = seed_movement('Box Step-up', family: :gymnastics, pattern: :lunge, equipment: :box,
                                           skill_level: :basic)
burpee = seed_movement('Burpee', family: :gymnastics, pattern: :mixed, skill_level: :basic)
burpee_box_jump = seed_movement('Burpee Box Jump', family: :gymnastics, pattern: :mixed, equipment: :box,
                                                   skill_level: :intermediate)
burpee_box_jump_over = seed_movement('Burpee Box Jump-over', family: :gymnastics, pattern: :mixed,
                                                             equipment: :box, skill_level: :intermediate)
butterfly_pull_up = seed_movement('Butterfly Pull-up', family: :gymnastics, pattern: :pull,
                                                       equipment: :pull_up_bar, skill_level: :advanced)
chest_to_bar_pull_up = seed_movement('Chest-to-bar Pull-up', family: :gymnastics, pattern: :pull,
                                                             equipment: :pull_up_bar, skill_level: :intermediate)
chest_to_wall_handstand_push_up = seed_movement('Chest-to-wall Handstand Push-up', family: :gymnastics,
                                                                                   pattern: :inversion,
                                                                                   skill_level: :advanced)
clean = seed_movement('Clean', family: :weightlifting, pattern: :hinge, equipment: :barbell,
                               skill_level: :intermediate)
clean_and_jerk = seed_movement('Clean and Jerk', family: :weightlifting, pattern: :mixed, equipment: :barbell,
                                                 skill_level: :advanced)
clean_and_push_jerk = seed_movement('Clean and Push Jerk', family: :weightlifting, pattern: :mixed,
                                                           equipment: :barbell, skill_level: :advanced)
clean_squat = seed_movement('Clean Squat', family: :weightlifting, pattern: :squat, equipment: :barbell,
                                           skill_level: :intermediate)
deadlift = seed_movement('Deadlift', family: :weightlifting, pattern: :hinge, equipment: :barbell,
                                     skill_level: :basic)
dip = seed_movement('Dip', family: :gymnastics, pattern: :press, skill_level: :basic)
double_under = seed_movement('Double-under', family: :monostructural, pattern: :jump, equipment: :jump_rope,
                                             skill_level: :intermediate)
dumbbell_bench_press = seed_movement('Dumbbell Bench Press', family: :weightlifting, pattern: :press,
                                                             equipment: :dumbbell, skill_level: :basic)
dumbbell_box_step_up = seed_movement('Dumbbell Box Step-up', family: :weightlifting, pattern: :lunge,
                                                             equipment: :dumbbell, skill_level: :intermediate)
dumbbell_clean = seed_movement('Dumbbell Clean', family: :weightlifting, pattern: :hinge, equipment: :dumbbell,
                                                 skill_level: :intermediate)
dumbbell_deadlift = seed_movement('Dumbbell Deadlift', family: :weightlifting, pattern: :hinge,
                                                       equipment: :dumbbell, skill_level: :basic)
dumbbell_farmers_carry = seed_movement('Dumbbell Farmers Carry', family: :weightlifting, pattern: :carry,
                                                                 equipment: :dumbbell, skill_level: :basic)
dumbbell_front_squat = seed_movement('Dumbbell Front Squat', family: :weightlifting, pattern: :squat,
                                                             equipment: :dumbbell, skill_level: :basic)
dumbbell_front_rack_lunge = seed_movement('Dumbbell Front-rack Lunge', family: :weightlifting, pattern: :lunge,
                                                                       equipment: :dumbbell, skill_level: :intermediate)
dumbbell_hang_clean = seed_movement('Dumbbell Hang Clean', family: :weightlifting, pattern: :hinge,
                                                           equipment: :dumbbell, skill_level: :intermediate)
dumbbell_hang_clean_and_jerk = seed_movement('Dumbbell Hang Clean and Jerk', family: :weightlifting,
                                                                             pattern: :mixed,
                                                                             equipment: :dumbbell,
                                                                             skill_level: :advanced)
dumbbell_hang_power_clean = seed_movement('Dumbbell Hang Power Clean', family: :weightlifting, pattern: :hinge,
                                                                       equipment: :dumbbell,
                                                                       skill_level: :intermediate)
dumbbell_overhead_squat = seed_movement('Dumbbell Overhead Squat', family: :weightlifting, pattern: :squat,
                                                                   equipment: :dumbbell, skill_level: :advanced)
dumbbell_overhead_walking_lunge = seed_movement('Dumbbell Overhead Walking Lunge', family: :weightlifting,
                                                                                   pattern: :lunge,
                                                                                   equipment: :dumbbell,
                                                                                   skill_level: :advanced)
dumbbell_power_clean = seed_movement('Dumbbell Power Clean', family: :weightlifting, pattern: :hinge,
                                                             equipment: :dumbbell, skill_level: :intermediate)
dumbbell_power_snatch = seed_movement('Dumbbell Power Snatch', family: :weightlifting, pattern: :hinge,
                                                               equipment: :dumbbell, skill_level: :advanced)
dumbbell_push_jerk = seed_movement('Dumbbell Push Jerk', family: :weightlifting, pattern: :press,
                                                         equipment: :dumbbell, skill_level: :intermediate)
dumbbell_push_press = seed_movement('Dumbbell Push Press', family: :weightlifting, pattern: :press,
                                                           equipment: :dumbbell, skill_level: :basic)
dumbbell_squat_snatch = seed_movement('Dumbbell Squat Snatch', family: :weightlifting, pattern: :squat,
                                                               equipment: :dumbbell, skill_level: :advanced)
dumbbell_thruster = seed_movement('Dumbbell Thruster', family: :weightlifting, pattern: :mixed,
                                                       equipment: :dumbbell, skill_level: :intermediate)
dumbbell_turkish_get_up = seed_movement('Dumbbell Turkish Get-up', family: :weightlifting, pattern: :mixed,
                                                                   equipment: :dumbbell,
                                                                   skill_level: :advanced)
forward_roll_from_support = seed_movement('Forward Roll From Support', family: :gymnastics, pattern: :rotation,
                                                                       skill_level: :advanced)
freestanding_handstand_push_up = seed_movement('Freestanding Handstand Push-up', family: :gymnastics,
                                                                                 pattern: :inversion,
                                                                                 skill_level: :advanced)
freestanding_shoulder_tap = seed_movement('Freestanding Shoulder Tap', family: :gymnastics,
                                                                       pattern: :inversion,
                                                                       skill_level: :advanced)
front_scale = seed_movement('Front Scale', family: :gymnastics, pattern: :hinge, skill_level: :intermediate)
front_squat = seed_movement('Front Squat', family: :weightlifting, pattern: :squat, equipment: :barbell,
                                           skill_level: :basic)
ghd_back_extension = seed_movement('GHD Back Extension', family: :gymnastics, pattern: :hinge,
                                                         skill_level: :intermediate)
ghd_hip_and_back_extension = seed_movement('GHD Hip and Back Extension', family: :gymnastics, pattern: :hinge,
                                                                         skill_level: :intermediate)
ghd_hip_extension = seed_movement('GHD Hip Extension', family: :gymnastics, pattern: :hinge,
                                                       skill_level: :intermediate)
ghd_sit_up = seed_movement('GHD Sit-up', family: :gymnastics, pattern: :rotation, skill_level: :intermediate)
glide_kip = seed_movement('Glide Kip', family: :gymnastics, pattern: :pull, skill_level: :advanced)
good_morning = seed_movement('Good Morning', family: :weightlifting, pattern: :hinge, equipment: :barbell,
                                             skill_level: :basic)
handstand = seed_movement('Handstand', family: :gymnastics, pattern: :inversion, skill_level: :intermediate)
handstand_pirouette = seed_movement('Handstand Pirouette', family: :gymnastics, pattern: :inversion,
                                                           skill_level: :advanced)
handstand_push_up = seed_movement('Handstand Push-up', family: :gymnastics, pattern: :inversion,
                                                       skill_level: :advanced)
handstand_walk = seed_movement('Handstand Walk', family: :gymnastics, pattern: :inversion,
                                                 skill_level: :advanced)
hang_clean = seed_movement('Hang Clean', family: :weightlifting, pattern: :hinge, equipment: :barbell,
                                         skill_level: :intermediate)
hang_clean_and_push_jerk = seed_movement('Hang Clean and Push Jerk', family: :weightlifting, pattern: :mixed,
                                                                     equipment: :barbell, skill_level: :advanced)
hang_power_clean = seed_movement('Hang Power Clean', family: :weightlifting, pattern: :hinge,
                                                     equipment: :barbell, skill_level: :intermediate)
hang_power_snatch = seed_movement('Hang Power Snatch', family: :weightlifting, pattern: :hinge,
                                                       equipment: :barbell, skill_level: :advanced)
hang_snatch = seed_movement('Hang Snatch', family: :weightlifting, pattern: :hinge, equipment: :barbell,
                                           skill_level: :advanced)
hanging_l_sit = seed_movement('Hanging L-sit', family: :gymnastics, pattern: :rotation,
                                               equipment: :pull_up_bar, skill_level: :intermediate)
hip_extensions = seed_movement('Hip Extensions', family: :gymnastics, pattern: :hinge,
                                                 skill_level: :basic)
inverted_burpee = seed_movement('Inverted Burpee', family: :gymnastics, pattern: :inversion,
                                                   skill_level: :advanced)
jumping_jack = seed_movement('Jumping Jack', family: :monostructural, pattern: :jump, skill_level: :basic)
jumping_lunge = seed_movement('Jumping Lunge', family: :gymnastics, pattern: :lunge, skill_level: :basic)
kettlebell_snatch = seed_movement('Kettlebell Snatch', family: :weightlifting, pattern: :hinge,
                                                       equipment: :kettlebell, skill_level: :advanced)
kettlebell_sumo_hi_pull = seed_movement('Kettlebell Sumo Hi Pull', family: :weightlifting, pattern: :pull,
                                                                   equipment: :kettlebell,
                                                                   skill_level: :intermediate)
kettlebell_swing = seed_movement('Kettlebell Swing', family: :weightlifting, pattern: :hinge,
                                                     equipment: :kettlebell, skill_level: :basic)
l_pull_up = seed_movement('L Pull-up', family: :gymnastics, pattern: :pull, equipment: :pull_up_bar,
                                       skill_level: :advanced)
l_sit_hold_on_matador = seed_movement('L Sit Hold on Matador', family: :gymnastics, pattern: :rotation,
                                                               skill_level: :intermediate)
l_sit = seed_movement('L-sit', family: :gymnastics, pattern: :rotation, skill_level: :intermediate)
l_sit_on_rings = seed_movement('L-sit on Rings', family: :gymnastics, pattern: :rotation, equipment: :rings,
                                                 skill_level: :intermediate)
l_sit_rope_climb = seed_movement('L-sit Rope Climb', family: :gymnastics, pattern: :pull, equipment: :rope,
                                                     skill_level: :advanced)
l_sit_to_shoulder_stand = seed_movement('L-sit to Shoulder Stand', family: :gymnastics,
                                                                   pattern: :inversion,
                                                                   equipment: :rings,
                                                                   skill_level: :advanced)
lateral_over_barbell_burpee = seed_movement('Lateral Over Barbell Burpee', family: :gymnastics,
                                                                           pattern: :mixed,
                                                                           equipment: :barbell,
                                                                           skill_level: :intermediate)
legless_rope_climb = seed_movement('Legless Rope Climb', family: :gymnastics, pattern: :pull,
                                                         equipment: :rope, skill_level: :advanced)
lunge = seed_movement('Lunge', family: :gymnastics, pattern: :lunge, skill_level: :basic)
lunge_with_plate_overhead = seed_movement('Lunge with plate overhead', family: :weightlifting,
                                                                       pattern: :lunge,
                                                                       skill_level: :intermediate)
medicine_ball_clean = seed_movement('Medicine-ball Clean', family: :weightlifting, pattern: :hinge,
                                                           equipment: :medicine_ball, skill_level: :basic)
modified_rope_climb = seed_movement('Modified Rope Climb', family: :gymnastics, pattern: :pull,
                                                           equipment: :rope, skill_level: :intermediate)
muscle_snatch = seed_movement('Muscle Snatch', family: :weightlifting, pattern: :hinge, equipment: :barbell,
                                               skill_level: :advanced)
muscle_up = seed_movement('Muscle-up', family: :gymnastics, pattern: :pull, skill_level: :advanced)
over_the_bar_burpee = seed_movement('Over the bar Burpee', family: :gymnastics, pattern: :mixed,
                                                           equipment: :barbell, skill_level: :intermediate)
over_the_medball_burpee = seed_movement('Over the medball Burpee', family: :gymnastics, pattern: :mixed,
                                                                   equipment: :medicine_ball,
                                                                   skill_level: :intermediate)
overhead_dumbbell_lunge = seed_movement('Overhead Dumbbell Lunge', family: :weightlifting, pattern: :lunge,
                                                                   equipment: :dumbbell,
                                                                   skill_level: :intermediate)
overhead_squat = seed_movement('Overhead Squat', family: :weightlifting, pattern: :squat,
                                                 equipment: :barbell, skill_level: :advanced)
power_clean = seed_movement('Power Clean', family: :weightlifting, pattern: :hinge, equipment: :barbell,
                                           skill_level: :intermediate)
power_clean_and_split_jerk = seed_movement('Power Clean and Split Jerk', family: :weightlifting,
                                                                         pattern: :mixed, equipment: :barbell,
                                                                         skill_level: :advanced)
power_snatch = seed_movement('Power Snatch', family: :weightlifting, pattern: :hinge, equipment: :barbell,
                                             skill_level: :advanced)
pull_over = seed_movement('Pull-over', family: :gymnastics, pattern: :pull, equipment: :pull_up_bar,
                                       skill_level: :advanced)
pull_up = seed_movement('Pull-up', family: :gymnastics, pattern: :pull, equipment: :pull_up_bar,
                                   skill_level: :intermediate)
push_jerk = seed_movement('Push Jerk', family: :weightlifting, pattern: :press, equipment: :barbell,
                                       skill_level: :intermediate)
push_press = seed_movement('Push Press', family: :weightlifting, pattern: :press, equipment: :barbell,
                                         skill_level: :basic)
push_up = seed_movement('Push-up', family: :gymnastics, pattern: :press, skill_level: :basic)
deficit_push_up = seed_movement('Deficit Push-up', family: :gymnastics, pattern: :press,
                                                   skill_level: :intermediate)
renegade_row = seed_movement('Renegade Row', family: :weightlifting, pattern: :pull, equipment: :dumbbell,
                                             skill_level: :intermediate)
rest = seed_movement('Rest', family: :rest, pattern: :rest, skill_level: :basic)
ring_dip = seed_movement('Ring Dip', family: :gymnastics, pattern: :press, equipment: :rings,
                                     skill_level: :intermediate)
ring_muscle_up = seed_movement('Ring Muscle-up', family: :gymnastics, pattern: :pull, equipment: :rings,
                                                 skill_level: :advanced)
ring_push_up = seed_movement('Ring Push-up', family: :gymnastics, pattern: :press, equipment: :rings,
                                             skill_level: :intermediate)
ring_row = seed_movement('Ring Row', family: :gymnastics, pattern: :pull, equipment: :rings,
                                     skill_level: :basic)
rope_climb = seed_movement('Rope Climb', family: :gymnastics, pattern: :pull, equipment: :rope,
                                         skill_level: :intermediate)
row = seed_movement('Row', family: :monostructural, pattern: :pull, equipment: :machine, skill_level: :basic)
run = seed_movement('Run', family: :monostructural, pattern: :locomotion, skill_level: :basic)
shoot_through = seed_movement('Shoot-through', family: :gymnastics, pattern: :mixed, skill_level: :intermediate)
shoulder_press = seed_movement('Shoulder Press', family: :weightlifting, pattern: :press, equipment: :barbell,
                                                 skill_level: :basic)
shoulder_to_overhead = seed_movement('Shoulder to Overhead', family: :weightlifting, pattern: :press,
                                                             equipment: :barbell, skill_level: :intermediate)
single_leg_squat_pistol = seed_movement('Single-leg Squat (Pistol)', family: :gymnastics, pattern: :squat,
                                                                     skill_level: :advanced)
single_under = seed_movement('Single-under', family: :monostructural, pattern: :jump, equipment: :jump_rope,
                                             skill_level: :basic)
sit_up = seed_movement('Sit-up', family: :gymnastics, pattern: :rotation, skill_level: :basic)
skin_the_cat = seed_movement('Skin the Cat', family: :gymnastics, pattern: :rotation, equipment: :rings,
                                             skill_level: :advanced)
slam_ball = seed_movement('Slam Ball', family: :weightlifting, pattern: :mixed, equipment: :medicine_ball,
                                       skill_level: :basic)
sled_drag = seed_movement('Sled Drag', family: :weightlifting, pattern: :locomotion, equipment: :sled,
                                       skill_level: :basic)
sled_pull = seed_movement('Sled Pull', family: :weightlifting, pattern: :pull, equipment: :sled,
                                       skill_level: :basic)
snatch = seed_movement('Snatch', family: :weightlifting, pattern: :hinge, equipment: :barbell,
                                 skill_level: :advanced)
snatch_balance = seed_movement('Snatch Balance', family: :weightlifting, pattern: :squat,
                                                 equipment: :barbell, skill_level: :advanced)
sots_press = seed_movement('Sots Press', family: :weightlifting, pattern: :press, equipment: :barbell,
                                         skill_level: :advanced)
split_clean = seed_movement('Split Clean', family: :weightlifting, pattern: :hinge, equipment: :barbell,
                                           skill_level: :advanced)
split_jerk = seed_movement('Split Jerk', family: :weightlifting, pattern: :press, equipment: :barbell,
                                         skill_level: :advanced)
split_snatch = seed_movement('Split Snatch', family: :weightlifting, pattern: :hinge, equipment: :barbell,
                                             skill_level: :advanced)
straddle_press_to_handstand = seed_movement('Straddle Press to Handstand', family: :gymnastics,
                                                                           pattern: :inversion,
                                                                           skill_level: :advanced)
strict_bar_muscle_up = seed_movement('Strict Bar Muscle-up', family: :gymnastics, pattern: :pull,
                                                             equipment: :pull_up_bar, skill_level: :advanced)
strict_chest_to_bar_pull_up = seed_movement('Strict Chest-to-bar Pull-up', family: :gymnastics,
                                                                           pattern: :pull,
                                                                           equipment: :pull_up_bar,
                                                                           skill_level: :advanced)
strict_handstand_push_up = seed_movement('Strict Handstand Push-up', family: :gymnastics,
                                                                     pattern: :inversion,
                                                                     skill_level: :advanced)
strict_knees_to_elbows = seed_movement('Strict Knees-to-elbows', family: :gymnastics, pattern: :rotation,
                                                                 equipment: :pull_up_bar,
                                                                 skill_level: :intermediate)
strict_muscle_up = seed_movement('Strict Muscle-up', family: :gymnastics, pattern: :pull,
                                                     skill_level: :advanced)
strict_pull_up = seed_movement('Strict Pull-up', family: :gymnastics, pattern: :pull,
                                                 equipment: :pull_up_bar, skill_level: :intermediate)
strict_toes_to_bar = seed_movement('Strict Toes-to-bar', family: :gymnastics, pattern: :rotation,
                                                         equipment: :pull_up_bar, skill_level: :intermediate)
strict_toes_to_rings = seed_movement('Strict Toes-to-rings', family: :gymnastics, pattern: :rotation,
                                                             equipment: :rings, skill_level: :intermediate)
sumo_deadlift = seed_movement('Sumo Deadlift', family: :weightlifting, pattern: :hinge,
                                               equipment: :barbell, skill_level: :basic)
sumo_deadlift_high_pull = seed_movement('Sumo Deadlift High Pull', family: :weightlifting, pattern: :pull,
                                                                   equipment: :barbell,
                                                                   skill_level: :intermediate)
swim = seed_movement('Swim', family: :monostructural, pattern: :locomotion, skill_level: :basic)
swing_to_backward_roll_to_support = seed_movement('Swing to Backward Roll to Support', family: :gymnastics,
                                                                                       pattern: :rotation,
                                                                                       equipment: :rings,
                                                                                       skill_level: :advanced)
tempo_jerk = seed_movement('Tempo Jerk', family: :weightlifting, pattern: :press, equipment: :barbell,
                                         skill_level: :intermediate)
thruster = seed_movement('Thruster', family: :weightlifting, pattern: :mixed, equipment: :barbell,
                                     skill_level: :intermediate)
toes_to_bar = seed_movement('Toes to Bar', family: :gymnastics, pattern: :rotation, equipment: :pull_up_bar,
                                           skill_level: :intermediate)
toes_to_bar_pull_up = seed_movement('Toes to Bar + Pull-up', family: :gymnastics, pattern: :mixed,
                                                             equipment: :pull_up_bar, skill_level: :advanced)
tuck_up = seed_movement('Tuck-up', family: :gymnastics, pattern: :rotation, skill_level: :basic)
v_up = seed_movement('V-up', family: :gymnastics, pattern: :rotation, skill_level: :basic)
walking_lunge = seed_movement('Walking Lunge', family: :gymnastics, pattern: :lunge, skill_level: :basic)
wall_walk = seed_movement('Wall Walk', family: :gymnastics, pattern: :inversion, skill_level: :intermediate)
wall_ball_shot = seed_movement('Wall-ball Shot', family: :weightlifting, pattern: :squat,
                                                 equipment: :medicine_ball, skill_level: :basic)
windshield_wiper = seed_movement('Windshield Wiper', family: :gymnastics, pattern: :rotation,
                                                     skill_level: :advanced)
zercher_squat = seed_movement('Zercher Squat', family: :weightlifting, pattern: :squat, equipment: :barbell,
                                               skill_level: :intermediate)

# Programs
CF_PROGRAM = Program.find_or_create_by(name: 'Crossfit.com')
CF_PROGRAM.subscriptions.find_or_create_by(user: admin) do |subscription|
  subscription.role = :owner
end

%w[
  benchmark_workouts
  hero_workouts
  cf_workouts
].each do |seed_file|
  seed_path = Rails.root.join('db/seeds', "#{seed_file}.rb")
  # Evaluate local seed files in this binding so movement locals are shared.
  # rubocop:disable Security/Eval
  eval(seed_path.read, binding, seed_path.to_s)
  # rubocop:enable Security/Eval
end
