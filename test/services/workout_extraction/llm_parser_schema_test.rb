require 'test_helper'

module WorkoutExtraction
  class LlmParserSchemaTest < ActiveSupport::TestCase
    test 'derived schemas still expose every field the model-backed properties should cover' do
      assert_equal(
        %i[reps duration_seconds load female_load male_load implement_count distance female_distance
           male_distance distance_unit distance_units_per_rep calories female_calories male_calories
           ladder_step_every ladder_exempt movement_name].sort,
        LlmParser::EXERCISE_SCHEMA[:properties].keys.sort
      )
      assert_equal(
        %i[name rounds time_seconds interval_scheme rest_seconds notes exercises].sort,
        LlmParser::SEGMENT_SCHEMA[:properties].keys.sort
      )
      assert_equal(
        %i[name rounds time interval ladder_step team_size score_type time_cap notes segments
           exercises extractable gap_reason].sort,
        LlmParser::WORKOUT_SCHEMA[:properties].keys.sort
      )
    end

    test 'distance_unit is auto-constrained to the enum values and stays plainly optional' do
      assert_equal({ type: 'string', enum: %w[meter foot inch] }, LlmParser::EXERCISE_SCHEMA[:properties][:distance_unit])
      assert_not_includes LlmParser::EXERCISE_SCHEMA[:required], 'distance_unit'
    end

    test 'score_type stays constrained to the workout-valid subset, not the full 12-value enum' do
      enum = LlmParser::WORKOUT_SCHEMA[:properties][:score_type][:enum]

      assert_equal(%w[calorie rep round time weight].sort, enum.sort)
    end

    test 'extractable and movement_name are the only strictly required fields in their schemas' do
      assert_equal({ type: 'boolean' }, LlmParser::WORKOUT_SCHEMA[:properties][:extractable])
      assert_equal(%w[extractable], LlmParser::WORKOUT_SCHEMA[:required])
      assert_equal({ type: 'string' }, LlmParser::EXERCISE_SCHEMA[:properties][:movement_name])
      assert_equal(%w[movement_name], LlmParser::EXERCISE_SCHEMA[:required])
      assert_equal(%w[name], LlmParser::SEGMENT_SCHEMA[:required])
    end

    test 'gap_reason is plainly optional, not required or nullable' do
      assert_equal({ type: 'string' }, LlmParser::WORKOUT_SCHEMA[:properties][:gap_reason])
      assert_not_includes LlmParser::WORKOUT_SCHEMA[:required], 'gap_reason'
    end

    # Neither call enforces its schema via output_config/json_schema anymore -- extraction is a
    # single call, and even that call (13 properties, two small nested arrays-of-objects) triggered
    # "Schema is too complex" once confirmed via the step logger. These schemas exist only as the
    # source SystemPrompt's field descriptions are derived from, so Anthropic's structured-outputs
    # property-count limits no longer apply -- kept here only as a style check, not a compiled-limit check.
    test 'no schema uses anyOf/nullable types anywhere, matching the plain required/optional style used throughout' do
      schemas = [LlmParser::WORKOUT_SCHEMA, LlmParser::SEGMENT_SCHEMA, LlmParser::EXERCISE_SCHEMA]

      schemas.each do |schema|
        assert_empty(schema[:properties].select { |_, prop| prop.key?(:anyOf) }, "#{schema} has an anyOf-typed property")
      end
    end
  end
end
