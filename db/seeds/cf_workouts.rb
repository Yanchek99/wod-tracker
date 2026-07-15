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
crossfit_workout_notes = 'Each 5-minute window begins with a 200-meter run, followed by max reps of the gymnastics movement. ' \
                         'Post total reps to comments. ' \
                         'Intermediate option: use wall-facing handstand shoulder taps, skin-the-cats, strict pull-ups, and push-ups. ' \
                         'Beginner option: use 100-meter runs with plank shoulder taps, ring hanging leg raises, ' \
                         'foot-assisted pull-ups, and hand-elevated push-ups. ' \
                         'Source: https://www.crossfit.com/260622'

crossfit_workout = Workout.find_or_create_by(name: 'CF-260622') do |workout|
  workout.score_type = :rep
  workout.notes = crossfit_workout_notes

  first_window = workout.segments.build(name: '0:00-5:00', time_seconds: 300, position: 1)
  first_window.exercises.build(movement: run, position: 1, reps: 1, distance: 200, distance_unit: :meter)
  first_window.exercises.build(movement: freestanding_shoulder_tap, position: 2, reps: 0)

  second_window = workout.segments.build(name: '5:00-10:00', time_seconds: 300, position: 2)
  second_window.exercises.build(movement: run, position: 1, reps: 1, distance: 200, distance_unit: :meter)
  second_window.exercises.build(movement: skin_the_cat, position: 2, reps: 0)

  third_window = workout.segments.build(name: '10:00-15:00', time_seconds: 300, position: 3)
  third_window.exercises.build(movement: run, position: 1, reps: 1, distance: 200, distance_unit: :meter)
  third_window.exercises.build(movement: l_pull_up, position: 2, reps: 0)

  fourth_window = workout.segments.build(name: '15:00-20:00', time_seconds: 300, position: 4)
  fourth_window.exercises.build(movement: run, position: 1, reps: 1, distance: 200, distance_unit: :meter)
  fourth_window.exercises.build(movement: deficit_push_up, position: 2, reps: 0,
                                female_distance: 2, male_distance: 4, distance_unit: :inch)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: crossfit_workout).update(posted_at: Date.new(2026, 6, 22))

# Example Workouts
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
  first_run = workout.segments.build(position: 1)
  first_run.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
  seg = workout.segments.build(rounds: 10, position: 2)
  seg.exercises.build(movement: handstand_push_up, position: 1, reps: 10)
  seg.exercises.build(movement: single_leg_squat_pistol, position: 2, reps: 10)
  final_run = workout.segments.build(position: 3)
  final_run.exercises.build(movement: run, position: 1, reps: 1, distance: 800, distance_unit: :meter)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: segmented).update(posted_at: Date.new(2018, 12, 2))

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
  tab1.exercises.build(movement: handstand_push_up, position: 1, duration_seconds: 20)
  tab1.exercises.build(movement: rest, position: 2, duration_seconds: 10)

  rest_after_tab1 = workout.segments.build(position: 2)
  rest_after_tab1.exercises.build(movement: rest, position: 1, duration_seconds: 60)

  tab2 = workout.segments.build(rounds: 8, position: 3)
  tab2.exercises.build(movement: single_leg_squat_pistol, position: 1, duration_seconds: 20)
  tab2.exercises.build(movement: rest, position: 2, duration_seconds: 10)

  rest_after_tab2 = workout.segments.build(position: 4)
  rest_after_tab2.exercises.build(movement: rest, position: 1, duration_seconds: 60)

  tab3 = workout.segments.build(rounds: 8, position: 5)
  tab3.exercises.build(movement: push_up, position: 1, duration_seconds: 20)
  tab3.exercises.build(movement: rest, position: 2, duration_seconds: 10)

  rest_after_tab3 = workout.segments.build(position: 6)
  rest_after_tab3.exercises.build(movement: rest, position: 1, duration_seconds: 60)

  tab4 = workout.segments.build(rounds: 8, position: 7)
  tab4.exercises.build(movement: jumping_lunge, position: 1, duration_seconds: 20)
  tab4.exercises.build(movement: rest, position: 2, duration_seconds: 10)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: tabata).update(posted_at: Date.new(2018, 12, 26))

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
  workout.score_type = :time
  workout.notes = 'Drag the sled 1,600 meters while carrying a barbell in the ' \
                  'front rack; the barbell and sled are loaded the same and the ' \
                  'sled attaches at the waist. Every time you stop, complete 15 ' \
                  'bent-over rows before resuming. Take strategic breaks to hold ' \
                  'a steady pace rather than dragging until forced to stop.'
  main = workout.segments.build(position: 1)
  main.exercises.build(movement: sled_drag, position: 1, reps: 1, distance: 1600, distance_unit: :meter,
                       female_load: 95, male_load: 135, load_unit: :lb,
                       notes: 'Carry a barbell in the front rack while dragging the waist sled; ' \
                              'barbell and sled loaded the same.')
  penalty = workout.segments.build(position: 2, name: 'Every time you stop')
  penalty.exercises.build(movement: bent_over_row, position: 1, reps: 15,
                          female_load: 95, male_load: 135, load_unit: :lb,
                          notes: 'Performed with the barbell. Log the total reps actually completed.')
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: sled_drag_carry).update(posted_at: Date.new(2026, 6, 20))
