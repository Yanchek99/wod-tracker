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
  workout.time = 20
  workout.score_type = :rep
  workout.notes = crossfit_workout_notes

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
  workout.exercises.build(movement: l_pull_up, segment: third_window, position: 2, reps: 0)

  fourth_window = workout.segments.build(name: '15:00-20:00', time_seconds: 300, position: 4)
  workout.exercises.build(movement: run, segment: fourth_window, position: 1,
                          reps: 1, distance: 200, distance_unit: :meter)
  workout.exercises.build(movement: deficit_push_up, segment: fourth_window, position: 2,
                          reps: 0, female_distance: 2, male_distance: 4, distance_unit: :inch)
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: crossfit_workout).update(posted_at: Date.new(2026, 6, 22))

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
  workout.exercises.build(movement: handstand_push_up, segment: seg, position: 1, reps: 10)
  workout.exercises.build(movement: single_leg_squat_pistol, segment: seg, position: 2, reps: 10)
  workout.exercises.build(movement: run, position: 4, reps: 1, distance: 800, distance_unit: :meter)
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
  workout.exercises.build(movement: handstand_push_up, segment: tab1, position: 1, duration_seconds: 20)
  workout.exercises.build(movement: rest, segment: tab1, position: 2, duration_seconds: 10)

  workout.exercises.build(movement: rest, position: 2, duration_seconds: 60)

  tab2 = workout.segments.build(rounds: 8, position: 3)
  workout.exercises.build(movement: single_leg_squat_pistol, segment: tab2, position: 1, duration_seconds: 20)
  workout.exercises.build(movement: rest, segment: tab2, position: 2, duration_seconds: 10)

  workout.exercises.build(movement: rest, position: 4, duration_seconds: 60)

  tab3 = workout.segments.build(rounds: 8, position: 5)
  workout.exercises.build(movement: push_up, segment: tab3, position: 1, duration_seconds: 20)
  workout.exercises.build(movement: rest, segment: tab3, position: 2, duration_seconds: 10)

  workout.exercises.build(movement: rest, position: 6, duration_seconds: 60)

  tab4 = workout.segments.build(rounds: 8, position: 7)
  workout.exercises.build(movement: jumping_lunge, segment: tab4, position: 1, duration_seconds: 20)
  workout.exercises.build(movement: rest, segment: tab4, position: 2, duration_seconds: 10)
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
  workout.rounds = 1
  workout.score_type = :time
  workout.notes = 'Drag the sled 1,600 meters while carrying a barbell in the ' \
                  'front rack; the barbell and sled are loaded the same and the ' \
                  'sled attaches at the waist. Every time you stop, complete 15 ' \
                  'bent-over rows before resuming. Take strategic breaks to hold ' \
                  'a steady pace rather than dragging until forced to stop.'
  workout.exercises.build(movement: sled_drag, position: 1, reps: 1, distance: 1600, distance_unit: :meter,
                          female_load: 95, male_load: 135, load_unit: :lb,
                          notes: 'Carry a barbell in the front rack while dragging the waist sled; ' \
                                 'barbell and sled loaded the same.')
  penalty = workout.segments.build(position: 2, name: 'Every time you stop')
  workout.exercises.build(movement: bent_over_row, segment: penalty, position: 1, reps: 15,
                          female_load: 95, male_load: 135, load_unit: :lb,
                          notes: 'Performed with the barbell. Log the total reps actually completed.')
end

CF_PROGRAM.schedules.find_or_initialize_by(workout: sled_drag_carry).update(posted_at: Date.new(2026, 6, 20))
