require 'test_helper'

module CfWorkout
  class WorkoutParserCorpusTest < ActiveSupport::TestCase
    def workout_page(slug:, body_text:)
      WorkoutPage.new(date: nil, slug: slug, title: nil, body_html: nil, body_text: body_text, description: nil,
                      scaling: nil, rest_day: false, previous_slug: nil, next_slug: nil)
    end

    # Not fixtures: test/helpers/measurable_helper_test.rb creates these same movement names
    # dynamically per-test, which would collide with a permanent global fixture of the same name.
    def box_jump = Movement.find_or_create_by(name: 'Box Jump')
    def burpee_box_jump_over = Movement.find_or_create_by(name: 'Burpee Box Jump-over')
    def wall_ball_shot = Movement.find_or_create_by(name: 'Wall-ball Shot')
    def muscle_up = Movement.find_or_create_by(name: 'Muscle-up')
    def bike = Movement.find_or_create_by(name: 'Bike')

    test '180110: AMRAP with a load shared across two movements, excluding the bodyweight rope climb' do
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
        .to_return(status: 200, body: cf_workout_fixture('legacy_with_scaling.html'))

      page = Fetcher.call(Date.new(2018, 1, 10))
      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 'CF-180110', workout.name
      assert_equal 'rep', workout.score_type
      assert_equal 10, workout.time
      assert_equal 3, workout.exercises.length

      snatch, lunge, rope_climb = workout.exercises.sort_by(&:position)
      assert_equal movements(:power_snatch), snatch.movement
      assert_equal [5, 65, 95], [snatch.reps, snatch.female_load, snatch.male_load]
      assert_equal movements(:overhead_walking_lunge), lunge.movement
      assert_equal [10, 65, 95], [lunge.reps, lunge.female_load, lunge.male_load]
      assert_equal movements(:rope_climb), rope_climb.movement
      assert_equal 1, rope_climb.reps
      assert_nil rope_climb.female_load
    end

    test '260620: a real instructional sentence embedded in the body fails closed rather than guessing' do
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/260620})
        .to_return(status: 200, body: cf_workout_fixture('modern_multi_part.html'))
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2026/06/20})
        .to_return(status: 301, headers: { 'Location' => '/260620' })

      page = Fetcher.call(Date.new(2026, 6, 20))

      error = assert_raises(WorkoutParser::UnparseableError) { WorkoutParser.call(page) }
      assert_includes error.message, 'Any time you stop'
    end

    test '260710: an open-ended ascending AMRAP ladder keeps its first rung and barbell load' do
      body = "Complete as many rounds as possible in 10 minutes of:\n3 burpee box jump-overs\n3 deadlifts\n" \
             "6 burpee box jump-overs\n6 deadlifts\n9 burpee box jump-overs\n9 deadlifts\nEtc.\n\n" \
             "♀ 125-lb barbell\n♂ 185-lb barbell"
      page = workout_page(slug: '260710', body_text: body)
      burpee_box_jump_over_movement = burpee_box_jump_over

      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 'rep', workout.score_type
      assert_equal 10, workout.time
      assert_equal 3, workout.ladder_step
      assert_equal 2, workout.exercises.length

      burpee_box_jump_over, deadlift = workout.exercises.sort_by(&:position)
      assert_equal [burpee_box_jump_over_movement, 3], [burpee_box_jump_over.movement, burpee_box_jump_over.reps]
      assert_equal [movements(:deadlift), 3], [deadlift.movement, deadlift.reps]
      assert_equal [125, 185], [deadlift.female_load, deadlift.male_load]
    end

    test '260406: a "Partition the reps any way." boilerplate instruction is dropped, not treated as an exercise line' do
      body = "For time:\n800-meter run\n80 pull-ups\n80 deadlifts\n800-meter run\n\n" \
             "Partition the pull-up and deadlift reps any way.\n\n" \
             "♀ 95-lb barbell\n♂ 135-lb barbell\n\nPost time to comments."
      page = workout_page(slug: '260406', body_text: body)

      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 4, workout.exercises.length
      by_movement = workout.exercises.group_by(&:movement)
      assert_equal 2, by_movement[movements(:run)].length
      assert_equal 1, by_movement[movements(:pull_up)].length
      deadlift = by_movement[movements(:deadlift)].first
      assert_equal [95, 135], [deadlift.female_load, deadlift.male_load]

      notes = workout.notes.to_plain_text.strip
      assert_equal "Partition the pull-up and deadlift reps any way.\nPost time to comments.", notes
      assert_not_includes notes, '800-meter run'
      assert_not_includes notes, '135-lb barbell'
    end

    test 'Fran: rep-ladder with a bare-movement-only line, load applies to the thruster but not the pull-up' do
      page = workout_page(slug: '300201', body_text: "21-15-9 reps for time of:\nThrusters\nPull-ups\n\nMen: 95 lb.\nWomen: 65 lb.")

      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 'time', workout.score_type
      assert_equal '21-15-9', workout.interval
      thruster, pull_up = workout.exercises.sort_by(&:position)
      assert_equal movements(:thruster), thruster.movement
      assert_equal [1, 65, 95], [thruster.reps, thruster.female_load, thruster.male_load]
      assert_equal movements(:pull_up), pull_up.movement
      assert_equal 1, pull_up.reps
      assert_nil pull_up.female_load
    end

    test 'EMOM: every-minute-on-the-minute with no prescription block' do
      page = workout_page(slug: '300202', body_text: "Every minute on the minute for 10 minutes:\n5 burpees\n10 air squats")

      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 'rep', workout.score_type
      assert_equal 10, workout.time
      assert_equal 10, workout.rounds
      burpee, squat = workout.exercises.sort_by(&:position)
      assert_equal [movements(:burpee), 5], [burpee.movement, burpee.reps]
      assert_equal [movements(:squat), 10], [squat.movement, squat.reps]
    end

    test 'find-a-1-rep-max: a single lifting line with the load-zero sentinel' do
      page = workout_page(slug: '300203', body_text: 'Find a 1-rep-max back squat.')

      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 'weight', workout.score_type
      assert_equal 1, workout.exercises.length
      exercise = workout.exercises.first
      assert_equal movements(:back_squat), exercise.movement
      assert_equal [1, 0], [exercise.reps, exercise.load]
    end

    test 'CFJ-181202: sequential multi-part with a bare "Then," continuation back at top level' do
      body = "For time:\nRun 800 meters\nThen, 10 rounds of the couplet:\n10 handstand push-ups\n" \
             "10 single-leg squats\nThen, run 800 meters"
      page = workout_page(slug: '300204', body_text: body)

      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 'time', workout.score_type
      top_level = workout.exercises.select { |exercise| exercise.segment.blank? }.sort_by(&:position)
      assert_equal 2, top_level.length
      assert_equal [movements(:run), movements(:run)], top_level.map(&:movement)
      assert_equal [800, 800], top_level.map(&:distance)

      assert_equal 1, workout.segments.length
      segment = workout.segments.first
      assert_equal 10, segment.rounds
      segment_exercises = workout.exercises.select { |exercise| exercise.segment == segment }.sort_by(&:position)
      hspu, single_leg_squat = segment_exercises
      assert_equal [movements(:handstand_push_up), 10], [hspu.movement, hspu.reps]
      assert_equal [movements(:single_leg_squat), 10], [single_leg_squat.movement, single_leg_squat.reps]
    end

    test 'CF-260622: time-windowed multi-part with a prescription binding across segments' do
      body = "On a 20-minute clock for total reps:\n0:00-5:00:\n200-meter run\nMax freestanding shoulder taps\n\n" \
             "5:00-10:00:\n200-meter run\nMax skin-the-cats\n\n10:00-15:00:\n200-meter run\nMax L pull-ups\n\n" \
             "15:00-20:00:\n200-meter run\nMax deficit push-ups\n\nFemale 2-inch deficit\nMale 4-inch deficit"
      page = workout_page(slug: '300205', body_text: body)

      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 4, workout.segments.length
      windows = workout.segments.sort_by(&:position)
      assert_equal ['0:00-5:00', '5:00-10:00', '10:00-15:00', '15:00-20:00'], windows.map(&:name)
      assert(windows.all? { |segment| segment.time_seconds == 300 })

      # segment.exercises is empty on unsaved records (Exercise belongs_to both :workout and
      # :segment; building via workout.exercises.build(segment:) doesn't populate the Segment
      # side's in-memory has_many for a new record) -- filter from workout.exercises instead.
      segment_exercises = ->(segment) { workout.exercises.select { |exercise| exercise.segment == segment } }

      gymnastics_movements = windows.map { |segment| segment_exercises.call(segment).max_by(&:position).movement }
      assert_equal [movements(:freestanding_shoulder_tap), movements(:skin_the_cat), movements(:l_pull_up),
                    movements(:deficit_push_up)], gymnastics_movements

      deficit_push_up = segment_exercises.call(windows.last).max_by(&:position)
      assert_equal 0, deficit_push_up.reps
      assert_equal [2, 4], [deficit_push_up.female_distance, deficit_push_up.male_distance]
      assert_equal :inch, deficit_push_up.distance_unit.to_sym

      other_gymnastics = windows[0..2].map { |segment| segment_exercises.call(segment).max_by(&:position) }
      assert(other_gymnastics.all? { |exercise| exercise.female_distance.nil? })
    end

    test 'chipper: one Rx line encodes three different equipment dimensions across repeated movements' do
      body = "For time:\n10 deadlifts\n20 pull-ups\n30 wall-ball shots\n40 box jumps\n1,000-meter row\n" \
             "40 box jumps\n30 wall-ball shots\n20 pull-ups\n10 deadlifts\n\n" \
             "♀ 185-lb barbell, 20-inch box, and 14-lb medicine ball to a 9-foot target\n" \
             '♂ 275-lb barbell, 24-inch box, and 20-lb medicine ball to a 10-foot target'
      page = workout_page(slug: '300206', body_text: body)
      box_jump_movement = box_jump
      wall_ball_shot_movement = wall_ball_shot

      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 9, workout.exercises.length
      by_movement = workout.exercises.group_by(&:movement)

      by_movement[movements(:deadlift)].each { |exercise| assert_equal [185, 275], [exercise.female_load, exercise.male_load] }
      by_movement[box_jump_movement].each do |exercise|
        assert_equal [20, 24], [exercise.female_distance, exercise.male_distance]
        assert_equal :inch, exercise.distance_unit.to_sym
      end
      by_movement[wall_ball_shot_movement].each do |exercise|
        assert_equal [14, 20], [exercise.female_load, exercise.male_load]
        assert_equal [9, 10], [exercise.female_distance, exercise.male_distance]
        assert_equal :foot, exercise.distance_unit.to_sym
      end
      by_movement[movements(:pull_up)].each { |exercise| assert_nil exercise.female_load }
      assert_nil by_movement[movements(:row)].first.female_load
    end

    test '260411: a redundant couplet with calorie-based row lines and no gendered calorie split' do
      body = "For time:\n40-calorie row\n15 muscle-ups\n40-calorie row\n10 muscle-ups\n40-calorie row\n" \
             "5 muscle-ups\n\nPost time to the comments."
      page = workout_page(slug: '300207', body_text: body)
      muscle_up_movement = muscle_up

      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 'time', workout.score_type
      assert_equal 6, workout.exercises.length

      row_exercises = workout.exercises.select { |exercise| exercise.movement == movements(:row) }
      assert_equal 3, row_exercises.length
      row_exercises.each do |exercise|
        assert_equal [1, 40], [exercise.reps, exercise.calories]
        assert_nil exercise.distance
        assert_nil exercise.distance_unit
      end

      muscle_up_exercises = workout.exercises.select { |exercise| exercise.movement == muscle_up_movement }
      assert_equal [15, 10, 5], muscle_up_exercises.sort_by(&:position).map(&:reps)
    end

    test '260415: an inline gender-split calorie line ("24/30-calorie bike")' do
      body = "For time:\n15 power snatches\n24/30-calorie bike\n15 power snatches\n\n" \
             "♀ 75-lb barbell\n♂ 115-lb barbell\n\nPost time to comments."
      page = workout_page(slug: '260415', body_text: body)
      bike_movement = bike

      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 'time', workout.score_type
      assert_equal 3, workout.exercises.length

      snatch_exercises = workout.exercises.select { |exercise| exercise.movement == movements(:power_snatch) }
      snatch_exercises.each { |exercise| assert_equal [15, 75, 115], [exercise.reps, exercise.female_load, exercise.male_load] }

      bike_exercise = workout.exercises.find { |exercise| exercise.movement == bike_movement }
      assert_equal [1, 24, 30], [bike_exercise.reps, bike_exercise.female_calories, bike_exercise.male_calories]
      assert_nil bike_exercise.calories
      assert_nil bike_exercise.distance
      assert_nil bike_exercise.distance_unit
    end

    test '260711: a repeated Open workout titled "Open Workout <n.n>" resolves to its catalog name' do
      named = Workout.create!(name: 'Open 20.5', score_type: :time, time_cap_seconds: 1200)
      body = "Open Workout 20.5\n\nFor time, partitioned any way:\n99 completely unparseable gibberish (each)"
      page = workout_page(slug: '260711', body_text: body)

      workout = WorkoutParser.call(page)

      assert_equal named, workout
    end

    test "260101: a bare-number rerun doesn't loosely match a trailing-letter catalog variant" do
      Workout.create!(name: 'Open 15.1a', score_type: :time)
      exact = Workout.create!(name: 'Open 15.1', score_type: :time)
      body = "Open Workout 15.1\n\nFor time, partitioned any way:\n99 completely unparseable gibberish (each)"
      page = workout_page(slug: '260101', body_text: body)

      workout = WorkoutParser.call(page)

      assert_equal exact, workout
    end
  end
end
