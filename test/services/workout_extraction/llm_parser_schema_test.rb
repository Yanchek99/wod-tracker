require 'test_helper'

module WorkoutExtraction
  class LlmParserSchemaTest < ActiveSupport::TestCase
    test 'derived schemas still expose every field the model-backed properties should cover' do
      assert_equal(
        %i[reps duration_seconds load female_load male_load implement_count distance female_distance
           male_distance distance_unit distance_units_per_rep calories female_calories male_calories
           ladder_step_every ladder_exempt movement_name].sort,
        LlmParser.exercise_schema[:properties].keys.sort
      )
      assert_equal(
        %i[name rounds time_seconds interval_scheme rest_seconds notes exercises].sort,
        LlmParser.segment_schema[:properties].keys.sort
      )
      assert_equal(
        %i[name rounds time interval ladder_step team_size score_type time_cap notes segments
           exercises extractable gap_reason].sort,
        LlmParser.workout_schema[:properties].keys.sort
      )
    end

    test 'schemas are exposed through lazy accessors instead of eager boot-time constants' do
      assert_respond_to LlmParser, :exercise_schema
      assert_respond_to LlmParser, :segment_schema
      assert_respond_to LlmParser, :workout_schema
      assert_not_respond_to LlmParser, :workout_schema_overrides

      assert_not_includes LlmParser.constants(false), :EXERCISE_SCHEMA
      assert_not_includes LlmParser.constants(false), :SEGMENT_SCHEMA
      assert_not_includes LlmParser.constants(false), :WORKOUT_SCHEMA
    end

    test 'distance_unit is auto-constrained to the enum values and stays plainly optional' do
      assert_equal({ type: 'string', enum: %w[meter foot inch] }, LlmParser.exercise_schema[:properties][:distance_unit])
      assert_not_includes LlmParser.exercise_schema[:required], 'distance_unit'
    end

    test 'score_type stays constrained to the workout-valid subset, not the full 12-value enum' do
      enum = LlmParser.workout_schema[:properties][:score_type][:enum]

      assert_equal(%w[calorie rep round time weight].sort, enum.sort)
    end

    test 'extractable and movement_name are the only strictly required fields in their schemas' do
      assert_equal({ type: 'boolean' }, LlmParser.workout_schema[:properties][:extractable])
      assert_equal(%w[extractable], LlmParser.workout_schema[:required])
      assert_equal({ type: 'string' }, LlmParser.exercise_schema[:properties][:movement_name])
      assert_equal(%w[movement_name], LlmParser.exercise_schema[:required])
      assert_equal(%w[name], LlmParser.segment_schema[:required])
    end

    test 'gap_reason is plainly optional, not required or nullable' do
      assert_equal({ type: 'string' }, LlmParser.workout_schema[:properties][:gap_reason])
      assert_not_includes LlmParser.workout_schema[:required], 'gap_reason'
    end

    # Neither call enforces its schema via output_config/json_schema anymore -- extraction is a
    # single call, and even that call (13 properties, two small nested arrays-of-objects) triggered
    # "Schema is too complex" once confirmed via the step logger. These schemas exist only as the
    # source SystemPrompt's field descriptions are derived from, so Anthropic's structured-outputs
    # property-count limits no longer apply -- kept here only as a style check, not a compiled-limit check.
    test 'no schema uses anyOf/nullable types anywhere, matching the plain required/optional style used throughout' do
      schemas = [LlmParser.workout_schema, LlmParser.segment_schema, LlmParser.exercise_schema]

      schemas.each do |schema|
        assert_empty(schema[:properties].select { |_, prop| prop.key?(:anyOf) }, "#{schema} has an anyOf-typed property")
      end
    end
  end
end
