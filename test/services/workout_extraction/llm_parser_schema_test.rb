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
        %i[name rounds time_seconds interval_scheme rest_seconds notes exercises].sort,
        LlmParser::SEGMENT_SCHEMA[:properties].keys.sort
      )
      assert_equal(
        %i[name rounds time interval ladder_step team_size score_type time_cap notes segments exercises
           extractable gap_reason].sort,
        LlmParser::SCHEMA[:properties].keys.sort
      )
    end

    test 'distance_unit is auto-constrained to the enum values, nullable like the rest of the detail fields' do
      assert_equal(
        { anyOf: [{ type: 'string', enum: %w[meter foot inch] }, { type: 'null' }] },
        LlmParser::EXERCISE_SCHEMA[:properties][:distance_unit]
      )
    end

    test 'score_type stays constrained to the workout-valid subset, not the full 12-value enum' do
      enum = LlmParser::SCHEMA[:properties][:score_type][:anyOf].find { |branch| branch[:enum] }[:enum]

      assert_equal(%w[calorie rep round time weight].sort, enum.sort)
    end

    test 'every property is required in every schema, so the LLM can never omit a key' do
      assert_equal(LlmParser::EXERCISE_SCHEMA[:properties].keys.map(&:to_s).sort, LlmParser::EXERCISE_SCHEMA[:required].sort)
      assert_equal(LlmParser::SEGMENT_SCHEMA[:properties].keys.map(&:to_s).sort, LlmParser::SEGMENT_SCHEMA[:required].sort)
      assert_equal(LlmParser::SCHEMA[:properties].keys.map(&:to_s).sort, LlmParser::SCHEMA[:required].sort)
    end

    test 'extractable and movement_name stay strictly non-nullable, since real logic branches on them' do
      assert_equal({ type: 'boolean' }, LlmParser::SCHEMA[:properties][:extractable])
      assert_equal({ type: 'string' }, LlmParser::EXERCISE_SCHEMA[:properties][:movement_name])
    end

    test 'gap_reason is nullable, since it only applies when extractable is false' do
      assert_equal({ anyOf: [{ type: 'string' }, { type: 'null' }] }, LlmParser::SCHEMA[:properties][:gap_reason])
    end
  end
end
