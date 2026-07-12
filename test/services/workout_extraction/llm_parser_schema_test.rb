require 'test_helper'

module WorkoutExtraction
  class LlmParserSchemaTest < ActiveSupport::TestCase
    test 'derived schemas still expose every field the model-backed properties should cover' do
      assert_equal(
        %i[reps duration_seconds load female_load male_load implement_count distance female_distance
           male_distance distance_unit distance_units_per_rep calories female_calories male_calories
           ladder_step_every ladder_exempt notes movement_name].sort,
        LlmParser::EXERCISE_SCHEMA[:properties].keys.sort
      )
      assert_equal(
        %i[name rounds time_seconds interval_scheme rest_seconds notes].sort,
        LlmParser::SEGMENT_OUTLINE_SCHEMA[:properties].keys.sort
      )
      assert_equal(
        %i[name rounds time interval ladder_step team_size score_type time_cap notes segments
           exercise_snippets extractable gap_reason].sort,
        LlmParser::WORKOUT_SHAPE_SCHEMA[:properties].keys.sort
      )
      assert_equal(%i[text segment_index].sort, LlmParser::EXERCISE_SNIPPET_SCHEMA[:properties].keys.sort)
      assert_equal(%i[exercises], LlmParser::EXERCISE_DETAILS_SCHEMA[:properties].keys)
    end

    test 'distance_unit is auto-constrained to the enum values and stays plainly optional' do
      assert_equal({ type: 'string', enum: %w[meter foot inch] }, LlmParser::EXERCISE_SCHEMA[:properties][:distance_unit])
      assert_not_includes LlmParser::EXERCISE_SCHEMA[:required], 'distance_unit'
    end

    test 'score_type stays constrained to the workout-valid subset, not the full 12-value enum' do
      enum = LlmParser::WORKOUT_SHAPE_SCHEMA[:properties][:score_type][:anyOf].find { |branch| branch[:enum] }[:enum]

      assert_equal(%w[calorie rep round time weight].sort, enum.sort)
    end

    test 'extractable and movement_name stay strictly non-nullable and required, since real logic branches on them' do
      assert_equal({ type: 'boolean' }, LlmParser::WORKOUT_SHAPE_SCHEMA[:properties][:extractable])
      assert_includes LlmParser::WORKOUT_SHAPE_SCHEMA[:required], 'extractable'
      assert_equal({ type: 'string' }, LlmParser::EXERCISE_SCHEMA[:properties][:movement_name])
      assert_includes LlmParser::EXERCISE_SCHEMA[:required], 'movement_name'
    end

    test 'gap_reason is required but nullable, since it only applies when extractable is false' do
      assert_equal({ anyOf: [{ type: 'string' }, { type: 'null' }] }, LlmParser::WORKOUT_SHAPE_SCHEMA[:properties][:gap_reason])
      assert_includes LlmParser::WORKOUT_SHAPE_SCHEMA[:required], 'gap_reason'
    end

    test 'exercise_snippets carry a nullable segment_index and a required text field' do
      properties = LlmParser::EXERCISE_SNIPPET_SCHEMA[:properties]

      assert_equal({ type: 'string' }, properties[:text])
      assert_equal({ anyOf: [{ type: 'integer' }, { type: 'null' }] }, properties[:segment_index])
      assert_equal(%w[text segment_index], LlmParser::EXERCISE_SNIPPET_SCHEMA[:required])
    end

    test 'call 1 (workout shape) property counts stay within Anthropic structured-outputs limits' do
      call_1_schemas = [LlmParser::WORKOUT_SHAPE_SCHEMA, LlmParser::SEGMENT_OUTLINE_SCHEMA, LlmParser::EXERCISE_SNIPPET_SCHEMA]

      assert_within_structured_output_limits(call_1_schemas)
    end

    test 'call 2 (exercise details) property counts stay within Anthropic structured-outputs limits' do
      call_2_schemas = [LlmParser::EXERCISE_DETAILS_SCHEMA, LlmParser::EXERCISE_SCHEMA]

      assert_within_structured_output_limits(call_2_schemas)
    end

    private

    def assert_within_structured_output_limits(schemas)
      total_optional = schemas.sum { |schema| schema[:properties].keys.map(&:to_s).length - schema[:required].length }
      total_nullable = schemas.sum { |schema| schema[:properties].count { |_, prop| prop.key?(:anyOf) } }

      assert_operator total_optional, :<=, 24, "optional count #{total_optional} exceeds Anthropic's limit of 24"
      assert_operator total_nullable, :<=, 16, "nullable count #{total_nullable} exceeds Anthropic's limit of 16"
    end
  end
end
