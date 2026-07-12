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

    test 'distance_unit is auto-constrained to the enum values instead of an unconstrained string' do
      assert_equal({ type: 'string', enum: %w[meter foot inch] }, LlmParser::EXERCISE_SCHEMA[:properties][:distance_unit])
    end

    test 'score_type stays constrained to the workout-valid subset, not the full 12-value enum' do
      assert_equal(%w[calorie rep round time weight].sort, LlmParser::SCHEMA[:properties][:score_type][:enum].sort)
    end

    test 'only extractable is required at the top level, so the LLM can decline without a schema violation' do
      assert_equal(%w[extractable], LlmParser::SCHEMA[:required])
    end
  end
end
