require 'test_helper'

module CfWod
  class WorkoutParserTest < ActiveSupport::TestCase
    def wod_page(slug:, body_text:)
      WodPage.new(date: nil, slug: slug, title: nil, body_html: nil, body_text: body_text, description: nil,
                  scaling: nil, rest_day: false, previous_slug: nil, next_slug: nil)
    end

    # Exercises are built via `segment.exercises.build(...)` (see CfWod::WorkoutParser), not
    # `workout.exercises.build(segment:)`, because a has_many :through :segments association
    # cannot autosave new records that were added directly to its own in-memory collection --
    # Rails raises ActiveRecord::HasManyThroughCantAssociateThroughHasOneOrManyReflection on
    # save otherwise. That means `workout.exercises` stays empty in memory on an unsaved,
    # freshly-parsed workout; read exercises via each segment instead.
    def workout_exercises(workout) = workout.segments.flat_map(&:exercises)

    test 'builds a valid, unsaved flat for-time workout with no prescription' do
      page = wod_page(slug: '300101', body_text: "For time:\n5 burpees")

      workout = WorkoutParser.call(page)

      assert_not workout.persisted?
      assert workout.valid?
      assert_equal 'CF-300101', workout.name
      assert_equal 'time', workout.score_type
      assert_equal 1, workout_exercises(workout).length
      exercise = workout_exercises(workout).first
      assert_equal movements(:burpee), exercise.movement
      assert_equal 5, exercise.reps
      assert_equal 1, exercise.position
      assert exercise.segment.present?
      assert_not exercise.segment.schemed?
      assert workout.notes.blank?
    end

    test 'leaves notes blank rather than duplicating the raw prose when nothing is left over' do
      body = "For time:\n800-meter run\n80 pull-ups\n80 deadlifts\n800-meter run\n\n" \
             "♀ 95-lb barbell\n♂ 135-lb barbell"
      page = wod_page(slug: '300107', body_text: body)

      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert workout.notes.blank?
    end

    test 'captures genuinely leftover boilerplate as notes, without the header or exercise lines' do
      body = "For time:\n800-meter run\n80 pull-ups\n80 deadlifts\n800-meter run\n\n" \
             "Partition the pull-up and deadlift reps any way.\n\n" \
             "♀ 95-lb barbell\n♂ 135-lb barbell\n\nPost time to comments."
      page = wod_page(slug: '300108', body_text: body)

      workout = WorkoutParser.call(page)

      assert workout.valid?
      notes = workout.notes.to_plain_text.strip
      assert_equal "Partition the pull-up and deadlift reps any way.\nPost time to comments.", notes
      assert_not_includes notes, '80 pull-ups'
      assert_not_includes notes, '95-lb'
      assert_not_includes notes, 'For time'
    end

    test 'builds a find-a-1-rep-max workout with the load-zero sentinel' do
      page = wod_page(slug: '300102', body_text: 'Find a 1-rep-max back squat.')

      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 'weight', workout.score_type
      exercise = workout_exercises(workout).first
      assert_equal movements(:back_squat), exercise.movement
      assert_equal 1, exercise.reps
      assert_equal 0, exercise.load
    end

    test 'marks only barbell-family movements load-bearing in a manually scored weight workout' do
      barbell_movements = load_bearing_parser_movements
      page = wod_page(
        slug: '300111',
        body_text: (['For load:'] + barbell_movements.map { |movement| "1 #{movement.name.downcase}" } + ['1 pull-up']).join("\n")
      )

      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 'weight', workout.score_type
      assert_not workout.calculated_lifting_score?
      exercises = workout_exercises(workout).index_by { |exercise| exercise.movement.name }
      barbell_movements.each { |movement| assert_equal 0, exercises.fetch(movement.name).load }
      assert_nil exercises.fetch(movements(:pull_up).name).load
    end

    test 'stores trailing text after a 1-rep-max header as notes, since nothing else models it' do
      page = wod_page(slug: '300109', body_text: "Find a 1-rep-max back squat.\n\nRest as needed between attempts.")

      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 'Rest as needed between attempts.', workout.notes.to_plain_text.strip
    end

    test 'raises UnparseableError when the movement is unrecognized' do
      page = wod_page(slug: '300103', body_text: "For time:\n5 completely unrecognized movements")

      assert_raises(WorkoutParser::UnparseableError) { WorkoutParser.call(page) }
    end

    test 'raises UnparseableError for an ambiguous Etc.-terminated ascending ladder' do
      page = wod_page(
        slug: '300110',
        body_text: "Complete as many rounds as possible in 10 minutes of:\n" \
                   "3 burpees\n3 deadlifts\nEtc."
      )

      error = assert_raises(WorkoutParser::UnparseableError) { WorkoutParser.call(page) }

      assert_includes error.message, 'ambiguous ascending ladder'
    end

    test 'builds a set-based lifting workout with the load-zero sentinel and the parsed reps-per-set' do
      front_squat = Movement.find_or_create_by(name: 'Front Squat')
      page = wod_page(slug: '300104', body_text: 'Front squat 3-3-3-3-3 reps')

      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 'weight', workout.score_type
      assert_equal 5, workout.governing_segment.rounds
      exercise = workout_exercises(workout).first
      assert_equal front_squat, exercise.movement
      assert_equal 3, exercise.reps
      assert_equal 0, exercise.load
    end

    test 'returns an existing named workout directly instead of re-parsing its prose' do
      named = Workout.create!(name: 'Test Named Hero', score_type: :time, team_size: 2)
      body = "Test Named Hero\n\nWith a partner, 5 rounds for time of:\n99 completely unparseable gibberish (each)"
      page = wod_page(slug: '300105', body_text: body)

      workout = WorkoutParser.call(page)

      assert_equal named, workout
    end

    test 'returns an existing workout when parsed content matches a differently named one' do
      existing = Workout.create!(name: 'Legacy Burpee Bench', score_type: :time)
      segment = existing.segments.create!(position: 1)
      segment.exercises.create!(movement: movements(:burpee), position: 1, reps: 5)
      existing.refresh_content_key!
      page = wod_page(slug: '300106', body_text: "For time:\n5 burpees")

      workout = WorkoutParser.call(page)

      assert_equal existing, workout
    end

    private

    def load_bearing_parser_movements
      [
        Movement.find_or_create_by!(name: 'Clean'),
        Movement.find_or_create_by!(name: 'Hang Clean'),
        Movement.find_or_create_by!(name: 'Hang Power Snatch'),
        Movement.find_or_create_by!(name: 'Clean and Push Jerk'),
        Movement.find_or_create_by!(name: 'Ground to Overhead'),
        Movement.find_or_create_by!(name: 'Power Clean and Split Jerk'),
        Movement.find_or_create_by!(name: 'Shoulder Press'),
        Movement.find_or_create_by!(name: 'Snatch Balance')
      ]
    end
  end
end
