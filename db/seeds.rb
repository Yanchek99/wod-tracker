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
abmat_sit_up = Movement.find_or_initialize_by(name: 'AbMat Sit-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:hinge] }, skill_level: :basic)
  movement.save!
end
air_squat = Movement.find_or_initialize_by(name: 'Air Squat').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:squat] }, skill_level: :basic)
  movement.save!
end
back_extensions = Movement.find_or_initialize_by(name: 'Back Extensions').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_extension] }, skill_level: :basic)
  movement.save!
end
back_scale = Movement.find_or_initialize_by(name: 'Back Scale').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:hinge] }, skill_level: :intermediate)
  movement.save!
end
back_squat = Movement.find_or_initialize_by(name: 'Back Squat').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:squat] }, equipment: :barbell,
                             skill_level: :basic)
  movement.save!
end
bar_muscle_up = Movement.find_or_initialize_by(name: 'Bar Muscle-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_pull] }, equipment: :pull_up_bar,
                             skill_level: :advanced)
  movement.save!
end
barbell_front_rack_lunge = Movement.find_or_initialize_by(name: 'Barbell Front-rack Lunge').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:squat] },
                             equipment: :barbell, skill_level: :intermediate)
  movement.save!
end
bench_press = Movement.find_or_initialize_by(name: 'Bench Press').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:horizontal_push] }, equipment: :barbell,
                             skill_level: :basic)
  movement.save!
end
bent_over_row = Movement.find_or_initialize_by(name: 'Bent-over Row').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:horizontal_pull] }, equipment: :barbell,
                             skill_level: :basic)
  movement.save!
end
body_blaster = Movement.find_or_initialize_by(name: 'Body Blaster').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:squat, :vertical_push, :vertical_pull] }, skill_level: :intermediate)
  movement.save!
end
box_jump = Movement.find_or_initialize_by(name: 'Box Jump').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [] }, equipment: :box, skill_level: :basic)
  movement.save!
end
box_step_up = Movement.find_or_initialize_by(name: 'Box Step-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:squat] }, equipment: :box,
                             skill_level: :basic)
  movement.save!
end
burpee = Movement.find_or_initialize_by(name: 'Burpee').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:squat, :vertical_push] }, skill_level: :basic)
  movement.save!
end
burpee_box_jump = Movement.find_or_initialize_by(name: 'Burpee Box Jump').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:squat, :vertical_push] }, equipment: :box,
                             skill_level: :intermediate)
  movement.save!
end
burpee_box_jump_over = Movement.find_or_initialize_by(name: 'Burpee Box Jump-over').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:squat, :vertical_push] },
                             equipment: :box, skill_level: :intermediate)
  movement.save!
end
butterfly_pull_up = Movement.find_or_initialize_by(name: 'Butterfly Pull-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_pull] },
                             equipment: :pull_up_bar, skill_level: :advanced)
  movement.save!
end
chest_to_bar_pull_up = Movement.find_or_initialize_by(name: 'Chest-to-bar Pull-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_pull] },
                             equipment: :pull_up_bar, skill_level: :intermediate)
  movement.save!
end
chest_to_wall_handstand_push_up = Movement.find_or_initialize_by(name: 'Chest-to-wall Handstand Push-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics,
                             function_roles: { primary: [:vertical_push] },
                             skill_level: :advanced)
  movement.save!
end
clean = Movement.find_or_initialize_by(name: 'Clean').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge, :squat], secondary: [:vertical_pull] },
                             equipment: :barbell,
                             skill_level: :intermediate)
  movement.save!
end
clean_and_jerk = Movement.find_or_initialize_by(name: 'Clean and Jerk').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge, :vertical_push],
                                               secondary: [:squat, :vertical_pull] },
                             equipment: :barbell,
                             skill_level: :advanced)
  movement.save!
end
clean_and_push_jerk = Movement.find_or_initialize_by(name: 'Clean and Push Jerk').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge, :vertical_push],
                                               secondary: [:squat, :vertical_pull] },
                             equipment: :barbell, skill_level: :advanced)
  movement.save!
end
clean_squat = Movement.find_or_initialize_by(name: 'Clean Squat').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:squat] }, equipment: :barbell,
                             skill_level: :intermediate)
  movement.save!
end
deadlift = Movement.find_or_initialize_by(name: 'Deadlift').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:hinge] }, equipment: :barbell,
                             skill_level: :basic)
  movement.save!
end
dip = Movement.find_or_initialize_by(name: 'Dip').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_push] }, skill_level: :basic)
  movement.save!
end
double_under = Movement.find_or_initialize_by(name: 'Double-under').tap do |movement|
  movement.assign_attributes(family: :monostructural, function_roles: { primary: [] }, equipment: :jump_rope,
                             skill_level: :intermediate)
  movement.save!
end
dumbbell_bench_press = Movement.find_or_initialize_by(name: 'Dumbbell Bench Press').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:horizontal_push] },
                             equipment: :dumbbell, skill_level: :basic)
  movement.save!
end
dumbbell_box_step_up = Movement.find_or_initialize_by(name: 'Dumbbell Box Step-up').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:squat] },
                             equipment: :dumbbell, skill_level: :intermediate)
  movement.save!
end
dumbbell_clean = Movement.find_or_initialize_by(name: 'Dumbbell Clean').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge, :squat], secondary: [:vertical_pull] },
                             equipment: :dumbbell,
                             skill_level: :intermediate)
  movement.save!
end
dumbbell_deadlift = Movement.find_or_initialize_by(name: 'Dumbbell Deadlift').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:hinge] },
                             equipment: :dumbbell, skill_level: :basic)
  movement.save!
end
dumbbell_farmers_carry = Movement.find_or_initialize_by(name: 'Dumbbell Farmers Carry').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [] },
                             equipment: :dumbbell, skill_level: :basic)
  movement.save!
end
dumbbell_front_squat = Movement.find_or_initialize_by(name: 'Dumbbell Front Squat').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:squat] },
                             equipment: :dumbbell, skill_level: :basic)
  movement.save!
end
dumbbell_front_rack_lunge = Movement.find_or_initialize_by(name: 'Dumbbell Front-rack Lunge').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:squat] },
                             equipment: :dumbbell, skill_level: :intermediate)
  movement.save!
end
dumbbell_hang_clean = Movement.find_or_initialize_by(name: 'Dumbbell Hang Clean').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge, :squat], secondary: [:vertical_pull] },
                             equipment: :dumbbell, skill_level: :intermediate)
  movement.save!
end
dumbbell_hang_clean_and_jerk = Movement.find_or_initialize_by(name: 'Dumbbell Hang Clean and Jerk').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge, :vertical_push],
                                               secondary: [:squat, :vertical_pull] },
                             equipment: :dumbbell,
                             skill_level: :advanced)
  movement.save!
end
dumbbell_hang_power_clean = Movement.find_or_initialize_by(name: 'Dumbbell Hang Power Clean').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:hinge] },
                             equipment: :dumbbell,
                             skill_level: :intermediate)
  movement.save!
end
dumbbell_overhead_squat = Movement.find_or_initialize_by(name: 'Dumbbell Overhead Squat').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:squat] },
                             equipment: :dumbbell, skill_level: :advanced)
  movement.save!
end
dumbbell_overhead_walking_lunge = Movement.find_or_initialize_by(name: 'Dumbbell Overhead Walking Lunge').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:squat] },
                             equipment: :dumbbell,
                             skill_level: :advanced)
  movement.save!
end
dumbbell_power_clean = Movement.find_or_initialize_by(name: 'Dumbbell Power Clean').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge], secondary: [:vertical_pull] },
                             equipment: :dumbbell, skill_level: :intermediate)
  movement.save!
end
dumbbell_power_snatch = Movement.find_or_initialize_by(name: 'Dumbbell Power Snatch').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge], secondary: [:vertical_pull, :vertical_push] },
                             equipment: :dumbbell, skill_level: :advanced)
  movement.save!
end
dumbbell_push_jerk = Movement.find_or_initialize_by(name: 'Dumbbell Push Jerk').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:vertical_push] },
                             equipment: :dumbbell, skill_level: :intermediate)
  movement.save!
end
dumbbell_push_press = Movement.find_or_initialize_by(name: 'Dumbbell Push Press').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:vertical_push] },
                             equipment: :dumbbell, skill_level: :basic)
  movement.save!
end
dumbbell_squat_snatch = Movement.find_or_initialize_by(name: 'Dumbbell Squat Snatch').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge, :squat],
                                               secondary: [:vertical_pull, :vertical_push] },
                             equipment: :dumbbell, skill_level: :advanced)
  movement.save!
end
dumbbell_thruster = Movement.find_or_initialize_by(name: 'Dumbbell Thruster').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:squat], secondary: [:vertical_push] },
                             equipment: :dumbbell, skill_level: :intermediate)
  movement.save!
end
dumbbell_turkish_get_up = Movement.find_or_initialize_by(name: 'Dumbbell Turkish Get-up').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:squat, :vertical_push, :trunk_flexion] },
                             equipment: :dumbbell,
                             skill_level: :advanced)
  movement.save!
end
forward_roll_from_support = Movement.find_or_initialize_by(name: 'Forward Roll From Support').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_flexion] },
                             skill_level: :advanced)
  movement.save!
end
freestanding_handstand_push_up = Movement.find_or_initialize_by(name: 'Freestanding Handstand Push-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics,
                             function_roles: { primary: [:vertical_push] },
                             skill_level: :advanced)
  movement.save!
end
freestanding_shoulder_tap = Movement.find_or_initialize_by(name: 'Freestanding Shoulder Tap').tap do |movement|
  movement.assign_attributes(family: :gymnastics,
                             function_roles: { primary: [] },
                             skill_level: :advanced)
  movement.save!
end
front_scale = Movement.find_or_initialize_by(name: 'Front Scale').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:hinge] }, skill_level: :intermediate)
  movement.save!
end
front_squat = Movement.find_or_initialize_by(name: 'Front Squat').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:squat] }, equipment: :barbell,
                             skill_level: :basic)
  movement.save!
end
ghd_back_extension = Movement.find_or_initialize_by(name: 'GHD Back Extension').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_extension] },
                             skill_level: :intermediate)
  movement.save!
end
ghd_hip_and_back_extension = Movement.find_or_initialize_by(name: 'GHD Hip and Back Extension').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_extension] },
                             skill_level: :intermediate)
  movement.save!
end
ghd_hip_extension = Movement.find_or_initialize_by(name: 'GHD Hip Extension').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_extension] },
                             skill_level: :intermediate)
  movement.save!
end
ghd_sit_up = Movement.find_or_initialize_by(name: 'GHD Sit-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_flexion] }, skill_level: :intermediate)
  movement.save!
end
glide_kip = Movement.find_or_initialize_by(name: 'Glide Kip').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_pull] }, skill_level: :advanced)
  movement.save!
end
good_morning = Movement.find_or_initialize_by(name: 'Good Morning').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:hinge] }, equipment: :barbell,
                             skill_level: :basic)
  movement.save!
end
handstand = Movement.find_or_initialize_by(name: 'Handstand').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [] }, skill_level: :intermediate)
  movement.save!
end
handstand_pirouette = Movement.find_or_initialize_by(name: 'Handstand Pirouette').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [] },
                             skill_level: :advanced)
  movement.save!
end
handstand_push_up = Movement.find_or_initialize_by(name: 'Handstand Push-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_push] },
                             skill_level: :advanced)
  movement.save!
end
handstand_walk = Movement.find_or_initialize_by(name: 'Handstand Walk').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [] },
                             skill_level: :advanced)
  movement.save!
end
hang_clean = Movement.find_or_initialize_by(name: 'Hang Clean').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge, :squat], secondary: [:vertical_pull] },
                             equipment: :barbell,
                             skill_level: :intermediate)
  movement.save!
end
hang_clean_and_push_jerk = Movement.find_or_initialize_by(name: 'Hang Clean and Push Jerk').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge, :vertical_push],
                                               secondary: [:squat, :vertical_pull] },
                             equipment: :barbell, skill_level: :advanced)
  movement.save!
end
hang_power_clean = Movement.find_or_initialize_by(name: 'Hang Power Clean').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge], secondary: [:vertical_pull] },
                             equipment: :barbell, skill_level: :intermediate)
  movement.save!
end
hang_power_snatch = Movement.find_or_initialize_by(name: 'Hang Power Snatch').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge], secondary: [:vertical_pull, :vertical_push] },
                             equipment: :barbell, skill_level: :advanced)
  movement.save!
end
hang_snatch = Movement.find_or_initialize_by(name: 'Hang Snatch').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge], secondary: [:vertical_pull, :vertical_push] },
                             equipment: :barbell,
                             skill_level: :advanced)
  movement.save!
end
hanging_l_sit = Movement.find_or_initialize_by(name: 'Hanging L-sit').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_flexion] },
                             equipment: :pull_up_bar, skill_level: :intermediate)
  movement.save!
end
hip_extensions = Movement.find_or_initialize_by(name: 'Hip Extensions').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_extension] },
                             skill_level: :basic)
  movement.save!
end
inverted_burpee = Movement.find_or_initialize_by(name: 'Inverted Burpee').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [] },
                             skill_level: :advanced)
  movement.save!
end
jumping_jack = Movement.find_or_initialize_by(name: 'Jumping Jack').tap do |movement|
  movement.assign_attributes(family: :monostructural, function_roles: { primary: [] }, skill_level: :basic)
  movement.save!
end
jumping_lunge = Movement.find_or_initialize_by(name: 'Jumping Lunge').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:squat] }, skill_level: :basic)
  movement.save!
end
kettlebell_snatch = Movement.find_or_initialize_by(name: 'Kettlebell Snatch').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:hinge] },
                             equipment: :kettlebell, skill_level: :advanced)
  movement.save!
end
kettlebell_sumo_hi_pull = Movement.find_or_initialize_by(name: 'Kettlebell Sumo Hi Pull').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:vertical_pull] },
                             equipment: :kettlebell,
                             skill_level: :intermediate)
  movement.save!
end
kettlebell_swing = Movement.find_or_initialize_by(name: 'Kettlebell Swing').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:hinge] },
                             equipment: :kettlebell, skill_level: :basic)
  movement.save!
end
l_pull_up = Movement.find_or_initialize_by(name: 'L Pull-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_pull] }, equipment: :pull_up_bar,
                             skill_level: :advanced)
  movement.save!
end
l_sit_hold_on_matador = Movement.find_or_initialize_by(name: 'L Sit Hold on Matador').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_flexion] },
                             skill_level: :intermediate)
  movement.save!
end
l_sit = Movement.find_or_initialize_by(name: 'L-sit').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_flexion] }, skill_level: :intermediate)
  movement.save!
end
l_sit_on_rings = Movement.find_or_initialize_by(name: 'L-sit on Rings').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_flexion] }, equipment: :rings,
                             skill_level: :intermediate)
  movement.save!
end
l_sit_rope_climb = Movement.find_or_initialize_by(name: 'L-sit Rope Climb').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_pull] }, equipment: :rope,
                             skill_level: :advanced)
  movement.save!
end
l_sit_to_shoulder_stand = Movement.find_or_initialize_by(name: 'L-sit to Shoulder Stand').tap do |movement|
  movement.assign_attributes(family: :gymnastics,
                             function_roles: { primary: [] },
                             equipment: :rings,
                             skill_level: :advanced)
  movement.save!
end
lateral_over_barbell_burpee = Movement.find_or_initialize_by(name: 'Lateral Over Barbell Burpee').tap do |movement|
  movement.assign_attributes(family: :gymnastics,
                             function_roles: { primary: [:squat, :vertical_push] },
                             equipment: :barbell,
                             skill_level: :intermediate)
  movement.save!
end
legless_rope_climb = Movement.find_or_initialize_by(name: 'Legless Rope Climb').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_pull] },
                             equipment: :rope, skill_level: :advanced)
  movement.save!
end
lunge = Movement.find_or_initialize_by(name: 'Lunge').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:squat] }, skill_level: :basic)
  movement.save!
end
lunge_with_plate_overhead = Movement.find_or_initialize_by(name: 'Lunge with plate overhead').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:squat] },
                             skill_level: :intermediate)
  movement.save!
end
medicine_ball_clean = Movement.find_or_initialize_by(name: 'Medicine-ball Clean').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge, :squat], secondary: [:vertical_pull] },
                             equipment: :medicine_ball, skill_level: :basic)
  movement.save!
end
modified_rope_climb = Movement.find_or_initialize_by(name: 'Modified Rope Climb').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_pull] },
                             equipment: :rope, skill_level: :intermediate)
  movement.save!
end
muscle_snatch = Movement.find_or_initialize_by(name: 'Muscle Snatch').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge], secondary: [:vertical_pull, :vertical_push] },
                             equipment: :barbell,
                             skill_level: :advanced)
  movement.save!
end
muscle_up = Movement.find_or_initialize_by(name: 'Muscle-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_pull] }, skill_level: :advanced)
  movement.save!
end
over_the_bar_burpee = Movement.find_or_initialize_by(name: 'Over the bar Burpee').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:squat, :vertical_push] },
                             equipment: :barbell, skill_level: :intermediate)
  movement.save!
end
over_the_medball_burpee = Movement.find_or_initialize_by(name: 'Over the medball Burpee').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:squat, :vertical_push] },
                             equipment: :medicine_ball,
                             skill_level: :intermediate)
  movement.save!
end
overhead_dumbbell_lunge = Movement.find_or_initialize_by(name: 'Overhead Dumbbell Lunge').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:squat] },
                             equipment: :dumbbell,
                             skill_level: :intermediate)
  movement.save!
end
overhead_squat = Movement.find_or_initialize_by(name: 'Overhead Squat').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:squat] },
                             equipment: :barbell, skill_level: :advanced)
  movement.save!
end
power_clean = Movement.find_or_initialize_by(name: 'Power Clean').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge], secondary: [:vertical_pull] },
                             equipment: :barbell,
                             skill_level: :intermediate)
  movement.save!
end
power_clean_and_split_jerk = Movement.find_or_initialize_by(name: 'Power Clean and Split Jerk').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge, :vertical_push], secondary: [:vertical_pull] },
                             equipment: :barbell,
                             skill_level: :advanced)
  movement.save!
end
power_snatch = Movement.find_or_initialize_by(name: 'Power Snatch').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge], secondary: [:vertical_pull, :vertical_push] },
                             equipment: :barbell,
                             skill_level: :advanced)
  movement.save!
end
pull_over = Movement.find_or_initialize_by(name: 'Pull-over').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_pull] }, equipment: :pull_up_bar,
                             skill_level: :advanced)
  movement.save!
end
pull_up = Movement.find_or_initialize_by(name: 'Pull-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_pull] }, equipment: :pull_up_bar,
                             skill_level: :intermediate)
  movement.save!
end
push_jerk = Movement.find_or_initialize_by(name: 'Push Jerk').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:vertical_push] }, equipment: :barbell,
                             skill_level: :intermediate)
  movement.save!
end
push_press = Movement.find_or_initialize_by(name: 'Push Press').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:vertical_push] }, equipment: :barbell,
                             skill_level: :basic)
  movement.save!
end
push_up = Movement.find_or_initialize_by(name: 'Push-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:horizontal_push] }, skill_level: :basic)
  movement.save!
end
deficit_push_up = Movement.find_or_initialize_by(name: 'Deficit Push-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:horizontal_push] },
                             skill_level: :intermediate)
  movement.save!
end
renegade_row = Movement.find_or_initialize_by(name: 'Renegade Row').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:horizontal_pull] }, equipment: :dumbbell,
                             skill_level: :intermediate)
  movement.save!
end
rest = Movement.find_or_initialize_by(name: 'Rest').tap do |movement|
  movement.assign_attributes(family: :rest, function_roles: { primary: [] }, skill_level: :basic)
  movement.save!
end
ring_dip = Movement.find_or_initialize_by(name: 'Ring Dip').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_push] }, equipment: :rings,
                             skill_level: :intermediate)
  movement.save!
end
ring_muscle_up = Movement.find_or_initialize_by(name: 'Ring Muscle-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_pull] }, equipment: :rings,
                             skill_level: :advanced)
  movement.save!
end
ring_push_up = Movement.find_or_initialize_by(name: 'Ring Push-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:horizontal_push] }, equipment: :rings,
                             skill_level: :intermediate)
  movement.save!
end
ring_row = Movement.find_or_initialize_by(name: 'Ring Row').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:horizontal_pull] }, equipment: :rings,
                             skill_level: :basic)
  movement.save!
end
rope_climb = Movement.find_or_initialize_by(name: 'Rope Climb').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_pull] }, equipment: :rope,
                             skill_level: :intermediate)
  movement.save!
end
row = Movement.find_or_initialize_by(name: 'Row').tap do |movement|
  movement.assign_attributes(family: :monostructural, function_roles: { primary: [:horizontal_pull] }, equipment: :machine, skill_level: :basic)
  movement.save!
end
run = Movement.find_or_initialize_by(name: 'Run').tap do |movement|
  movement.assign_attributes(family: :monostructural, function_roles: { primary: [] }, skill_level: :basic)
  movement.save!
end
shoot_through = Movement.find_or_initialize_by(name: 'Shoot-through').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:squat, :vertical_push] }, skill_level: :intermediate)
  movement.save!
end
shoulder_press = Movement.find_or_initialize_by(name: 'Shoulder Press').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:vertical_push] }, equipment: :barbell,
                             skill_level: :basic)
  movement.save!
end
shoulder_to_overhead = Movement.find_or_initialize_by(name: 'Shoulder to Overhead').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:vertical_push] },
                             equipment: :barbell, skill_level: :intermediate)
  movement.save!
end
single_leg_squat_pistol = Movement.find_or_initialize_by(name: 'Single-leg Squat (Pistol)').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:squat] },
                             skill_level: :advanced)
  movement.save!
end
single_under = Movement.find_or_initialize_by(name: 'Single-under').tap do |movement|
  movement.assign_attributes(family: :monostructural, function_roles: { primary: [] }, equipment: :jump_rope,
                             skill_level: :basic)
  movement.save!
end
sit_up = Movement.find_or_initialize_by(name: 'Sit-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_flexion] }, skill_level: :basic)
  movement.save!
end
skin_the_cat = Movement.find_or_initialize_by(name: 'Skin the Cat').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_flexion] }, equipment: :rings,
                             skill_level: :advanced)
  movement.save!
end
slam_ball = Movement.find_or_initialize_by(name: 'Slam Ball').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:hinge, :vertical_push] }, equipment: :medicine_ball,
                             skill_level: :basic)
  movement.save!
end
sled_drag = Movement.find_or_initialize_by(name: 'Sled Drag').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [] }, equipment: :sled,
                             skill_level: :basic)
  movement.save!
end
sled_pull = Movement.find_or_initialize_by(name: 'Sled Pull').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:vertical_pull] }, equipment: :sled,
                             skill_level: :basic)
  movement.save!
end
snatch = Movement.find_or_initialize_by(name: 'Snatch').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge, :squat],
                                               secondary: [:vertical_pull, :vertical_push] },
                             equipment: :barbell, skill_level: :advanced)
  movement.save!
end
snatch_balance = Movement.find_or_initialize_by(name: 'Snatch Balance').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:squat] },
                             equipment: :barbell, skill_level: :advanced)
  movement.save!
end
sots_press = Movement.find_or_initialize_by(name: 'Sots Press').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:vertical_push] }, equipment: :barbell,
                             skill_level: :advanced)
  movement.save!
end
split_clean = Movement.find_or_initialize_by(name: 'Split Clean').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge], secondary: [:vertical_pull] },
                             equipment: :barbell,
                             skill_level: :advanced)
  movement.save!
end
split_jerk = Movement.find_or_initialize_by(name: 'Split Jerk').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:vertical_push] }, equipment: :barbell,
                             skill_level: :advanced)
  movement.save!
end
split_snatch = Movement.find_or_initialize_by(name: 'Split Snatch').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge], secondary: [:vertical_pull, :vertical_push] },
                             equipment: :barbell,
                             skill_level: :advanced)
  movement.save!
end
straddle_press_to_handstand = Movement.find_or_initialize_by(name: 'Straddle Press to Handstand').tap do |movement|
  movement.assign_attributes(family: :gymnastics,
                             function_roles: { primary: [] },
                             skill_level: :advanced)
  movement.save!
end
strict_bar_muscle_up = Movement.find_or_initialize_by(name: 'Strict Bar Muscle-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_pull] },
                             equipment: :pull_up_bar, skill_level: :advanced)
  movement.save!
end
strict_chest_to_bar_pull_up = Movement.find_or_initialize_by(name: 'Strict Chest-to-bar Pull-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics,
                             function_roles: { primary: [:vertical_pull] },
                             equipment: :pull_up_bar,
                             skill_level: :advanced)
  movement.save!
end
strict_handstand_push_up = Movement.find_or_initialize_by(name: 'Strict Handstand Push-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics,
                             function_roles: { primary: [:vertical_push] },
                             skill_level: :advanced)
  movement.save!
end
strict_knees_to_elbows = Movement.find_or_initialize_by(name: 'Strict Knees-to-elbows').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_flexion] },
                             equipment: :pull_up_bar,
                             skill_level: :intermediate)
  movement.save!
end
strict_muscle_up = Movement.find_or_initialize_by(name: 'Strict Muscle-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_pull] },
                             skill_level: :advanced)
  movement.save!
end
strict_pull_up = Movement.find_or_initialize_by(name: 'Strict Pull-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:vertical_pull] },
                             equipment: :pull_up_bar, skill_level: :intermediate)
  movement.save!
end
strict_toes_to_bar = Movement.find_or_initialize_by(name: 'Strict Toes-to-bar').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_flexion] },
                             equipment: :pull_up_bar, skill_level: :intermediate)
  movement.save!
end
strict_toes_to_rings = Movement.find_or_initialize_by(name: 'Strict Toes-to-rings').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_flexion] },
                             equipment: :rings, skill_level: :intermediate)
  movement.save!
end
sumo_deadlift = Movement.find_or_initialize_by(name: 'Sumo Deadlift').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:hinge] },
                             equipment: :barbell, skill_level: :basic)
  movement.save!
end
sumo_deadlift_high_pull = Movement.find_or_initialize_by(name: 'Sumo Deadlift High Pull').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:vertical_pull] },
                             equipment: :barbell,
                             skill_level: :intermediate)
  movement.save!
end
swim = Movement.find_or_initialize_by(name: 'Swim').tap do |movement|
  movement.assign_attributes(family: :monostructural, function_roles: { primary: [] }, skill_level: :basic)
  movement.save!
end
swing_to_backward_roll_to_support = Movement.find_or_initialize_by(name: 'Swing to Backward Roll to Support').tap do |movement|
  movement.assign_attributes(family: :gymnastics,
                             function_roles: { primary: [:trunk_flexion] },
                             equipment: :rings,
                             skill_level: :advanced)
  movement.save!
end
tempo_jerk = Movement.find_or_initialize_by(name: 'Tempo Jerk').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:vertical_push] }, equipment: :barbell,
                             skill_level: :intermediate)
  movement.save!
end
thruster = Movement.find_or_initialize_by(name: 'Thruster').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:squat], secondary: [:vertical_push] },
                             equipment: :barbell,
                             skill_level: :intermediate)
  movement.save!
end
toes_to_bar = Movement.find_or_initialize_by(name: 'Toes to Bar').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_flexion] }, equipment: :pull_up_bar,
                             skill_level: :intermediate)
  movement.save!
end
toes_to_bar_pull_up = Movement.find_or_initialize_by(name: 'Toes to Bar + Pull-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_flexion, :vertical_pull] },
                             equipment: :pull_up_bar, skill_level: :advanced)
  movement.save!
end
tuck_up = Movement.find_or_initialize_by(name: 'Tuck-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_flexion] }, skill_level: :basic)
  movement.save!
end
v_up = Movement.find_or_initialize_by(name: 'V-up').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:trunk_flexion] }, skill_level: :basic)
  movement.save!
end
walking_lunge = Movement.find_or_initialize_by(name: 'Walking Lunge').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:squat] }, skill_level: :basic)
  movement.save!
end
wall_walk = Movement.find_or_initialize_by(name: 'Wall Walk').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [] }, skill_level: :intermediate)
  movement.save!
end
wall_ball_shot = Movement.find_or_initialize_by(name: 'Wall-ball Shot').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:squat], secondary: [:vertical_push] },
                             equipment: :medicine_ball, skill_level: :basic)
  movement.save!
end
windshield_wiper = Movement.find_or_initialize_by(name: 'Windshield Wiper').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [] },
                             skill_level: :advanced)
  movement.save!
end
zercher_squat = Movement.find_or_initialize_by(name: 'Zercher Squat').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:squat] }, equipment: :barbell,
                             skill_level: :intermediate)
  movement.save!
end

# Movements first introduced by the Open workouts
bar_facing_burpee = Movement.find_or_initialize_by(name: 'Bar-facing Burpee').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:squat, :vertical_push] },
                             equipment: :barbell, skill_level: :intermediate)
  movement.save!
end
box_jump_over = Movement.find_or_initialize_by(name: 'Box Jump-over').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [] }, equipment: :box,
                             skill_level: :basic)
  movement.save!
end
ground_to_overhead = Movement.find_or_initialize_by(name: 'Ground to Overhead').tap do |movement|
  movement.assign_attributes(family: :weightlifting,
                             function_roles: { primary: [:hinge, :vertical_push],
                                               secondary: [:squat, :vertical_pull] },
                             equipment: :barbell, skill_level: :intermediate)
  movement.save!
end
medicine_ball_box_step_over = Movement.find_or_initialize_by(name: 'Medicine-ball Box Step-over').tap do |movement|
  movement.assign_attributes(family: :weightlifting, function_roles: { primary: [:squat] },
                             equipment: :medicine_ball, skill_level: :intermediate)
  movement.save!
end
lateral_burpee_over_dumbbell = Movement.find_or_initialize_by(name: 'Lateral Burpee Over Dumbbell').tap do |movement|
  movement.assign_attributes(family: :gymnastics, function_roles: { primary: [:squat, :vertical_push] },
                             equipment: :dumbbell, skill_level: :intermediate)
  movement.save!
end

# Movements first introduced by the Hero workouts
bear_crawl = Movement.find_or_create_by(name: 'Bear Crawl')
bike = Movement.find_or_create_by(name: 'Bike')
broad_jump = Movement.find_or_create_by(name: 'Broad Jump')
barbell_back_rack_step_up = Movement.find_or_create_by(name: 'Barbell Back-rack Step-up')
barbell_step_up = Movement.find_or_create_by(name: 'Barbell Step-up')
bar_hang = Movement.find_or_create_by(name: 'Bar Hang')
burpee_bar_muscle_up = Movement.find_or_create_by(name: 'Burpee Bar Muscle-up')
burpee_chest_to_bar_pull_up = Movement.find_or_create_by(name: 'Burpee Chest-to-bar Pull-up')
burpee_muscle_up = Movement.find_or_create_by(name: 'Burpee Muscle-up')
burpee_pull_up = Movement.find_or_create_by(name: 'Burpee Pull-up')
burpee_to_target = Movement.find_or_create_by(name: 'Burpee to Target')
box_step_over = Movement.find_or_create_by(name: 'Box Step-over')
deficit_handstand_push_up = Movement.find_or_create_by(name: 'Deficit Handstand Push-up')
dumbbell_burpee_deadlift = Movement.find_or_create_by(name: 'Dumbbell Burpee Deadlift')
dumbbell_hang_split_snatch = Movement.find_or_create_by(name: 'Dumbbell Hang Split Snatch')
dumbbell_hang_squat_clean = Movement.find_or_create_by(name: 'Dumbbell Hang Squat Clean')
dumbbell_split_clean = Movement.find_or_create_by(name: 'Dumbbell Split Clean')
dumbbell_squat_clean = Movement.find_or_create_by(name: 'Dumbbell Squat Clean')
dumbbell_squat_clean_thruster = Movement.find_or_create_by(name: 'Dumbbell Squat Clean Thruster')
dumbbell_waiters_walk = Movement.find_or_create_by(name: 'Dumbbell Waiters Walk')
farmers_carry = Movement.find_or_create_by(name: 'Farmers Carry')
forward_roll = Movement.find_or_create_by(name: 'Forward Roll')
hand_release_push_up = Movement.find_or_create_by(name: 'Hand-release Push-up')
hang_squat_clean = Movement.find_or_create_by(name: 'Hang Squat Clean')
hanging_hip_touch = Movement.find_or_create_by(name: 'Hanging Hip Touch')
inverted_ring_lower = Movement.find_or_create_by(name: 'Inverted Ring Lower')
jerk = Movement.find_or_create_by(name: 'Jerk')
kettlebell_clean_and_jerk = Movement.find_or_create_by(name: 'Kettlebell Clean and Jerk')
kettlebell_goblet_squat = Movement.find_or_create_by(name: 'Kettlebell Goblet Squat')
kettlebell_thruster = Movement.find_or_create_by(name: 'Kettlebell Thruster')
knees_to_elbows = Movement.find_or_create_by(name: 'Knees-to-elbows')
overhead_walk = Movement.find_or_create_by(name: 'Overhead Walk')
overhead_walking_lunge = Movement.find_or_create_by(name: 'Overhead Walking Lunge')
parallette_handstand_push_up = Movement.find_or_create_by(name: 'Parallette Handstand Push-up')
plate_carry = Movement.find_or_create_by(name: 'Plate Carry')
ring_handstand_push_up = Movement.find_or_create_by(name: 'Ring Handstand Push-up')
sandbag_carry = Movement.find_or_create_by(name: 'Sandbag Carry')
sandbag_clean = Movement.find_or_create_by(name: 'Sandbag Clean')
shuttle_run = Movement.find_or_create_by(name: 'Shuttle Run')
sled_push = Movement.find_or_create_by(name: 'Sled Push')
squat_clean_thruster = Movement.find_or_create_by(name: 'Squat Clean Thruster')
squat_snatch = Movement.find_or_create_by(name: 'Squat Snatch')
stiff_legged_deadlift = Movement.find_or_create_by(name: 'Stiff-legged Deadlift')
strict_burpee_pull_up = Movement.find_or_create_by(name: 'Strict Burpee Pull-up')
toes_to_rings = Movement.find_or_create_by(name: 'Toes-to-rings')
triple_under = Movement.find_or_create_by(name: 'Triple-under')
turkish_get_up = Movement.find_or_create_by(name: 'Turkish Get-up')
wall_ball_two_for_one = Movement.find_or_create_by(name: 'Wall-ball Two-for-one')
weighted_pull_up = Movement.find_or_create_by(name: 'Weighted Pull-up')

# Movements first introduced by the partner/team Hero workouts
barbell_carry = Movement.find_or_create_by(name: 'Barbell Carry')
buddy_carry = Movement.find_or_create_by(name: 'Buddy Carry')
burpee_over_rower = Movement.find_or_create_by(name: 'Burpee Over Rower')
dumbbell_bent_over_row = Movement.find_or_create_by(name: 'Dumbbell Bent-over Row')
dumbbell_floor_press = Movement.find_or_create_by(name: 'Dumbbell Floor Press')
dumbbell_lunge = Movement.find_or_create_by(name: 'Dumbbell Lunge')
flutter_kick = Movement.find_or_create_by(name: 'Flutter Kick')
handstand_hold = Movement.find_or_create_by(name: 'Handstand Hold')

# Programs
CF_PROGRAM = Program.find_or_create_by(name: 'Crossfit.com')
CF_PROGRAM.subscriptions.find_or_create_by(user: admin) do |subscription|
  subscription.role = :owner
end

%w[
  benchmark_workouts
  hero_workouts
  open_workouts
  cf_workouts
].each do |seed_file|
  seed_path = Rails.root.join('db/seeds', "#{seed_file}.rb")
  # Evaluate local seed files in this binding so movement locals are shared.
  # rubocop:disable Security/Eval
  eval(seed_path.read, binding, seed_path.to_s)
  # rubocop:enable Security/Eval
end
