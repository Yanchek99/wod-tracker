require 'test_helper'

# Coverage for uniform-reps-times-N rep-scheme shapes (AXB_SCHEME's siblings in
# UNIFORM_SET_SCHEMES: "N Rounds: M <movement>", "N sets for load: M <movement>") and the two
# single-attempt/build-up rep-max phrasings ("Build to a N rep max", "1-rep max"). Split out of
# set_scheme_extractor_wave_test.rb (itself already split out of set_scheme_extractor_test.rb) to
# keep both classes within Metrics/ClassLength.
class SugarwodImport
  class SetSchemeExtractorUniformSchemeTest < ActiveSupport::TestCase
    test 'extracts a rep scheme from "Build to a N rep max" for a single logged attempt' do
      row = { title: 'Push Press', description: '15 minute clock Build to a 3 rep max',
              set_details: '[{"success":true,"load":175}]' }

      result = SetSchemeExtractor.call(row)

      assert_equal [{ reps: 3, load: 175 }], result
    end

    test 'applies a uniform rep scheme from "N Rounds: M <movement>"' do
      loads = Array.new(10, 245)
      row = { title: 'Back Squat', description: '10 Rounds: 1 Back Squat*Same heavy weight across all 10 sets',
              set_details: loads.map { |load| { success: true, load: load } }.to_json }

      result = SetSchemeExtractor.call(row)

      assert_equal Array.new(10) { { reps: 1, load: 245 } }, result
    end

    test 'applies a uniform single-rep scheme for a "1-rep max" build-up with multiple attempts' do
      loads = [295, 315, 335, 355, 365]
      row = { title: '230324', description: 'For load:1-rep max deadlift',
              set_details: loads.map { |load| { success: true, load: load } }.to_json }

      result = SetSchemeExtractor.call(row)

      assert_equal loads.map { |load| { reps: 1, load: load } }, result
    end

    test 'applies a uniform rep scheme from "N sets for load: M <movement>", dropping a failed set' do
      row = { title: '230413', description: '8 sets for load:2 shoulder presses',
              set_details: '[{"success":true,"load":115},{"success":true,"load":120},{"success":true,"load":125},' \
                           '{"success":true,"load":127},{"success":true,"load":130},{"success":false,"load":133},' \
                           '{"success":true,"load":125},{"success":true,"load":125}]' }

      result = SetSchemeExtractor.call(row)

      expected_loads = [115, 120, 125, 127, 130, 125, 125]
      assert_equal expected_loads.map { |load| { reps: 2, load: load } }, result
    end

    test 'applies a uniform interval scheme from "On the Minute x N: M reps"' do
      row = { title: 'Pausing Front Squat', description: 'On the Minute x 8: 2 Pausing Front Squats (2 Seconds)',
              set_details: '[{"success":true,"load":95},{"success":true,"load":115},{"success":true,"load":135},{"success":true,"load":145},' \
                           '{"success":true,"load":155},{"success":true,"load":165},{"success":true,"load":175},{"success":true,"load":185}]' }

      result = SetSchemeExtractor.call(row)

      assert_equal Array.new(8) { |i| { reps: 2, load: [95, 115, 135, 145, 155, 165, 175, 185][i] } }, result
    end

    test 'applies a uniform interval scheme from "On the X:XX x N Sets: M reps"' do
      row = { title: 'Power Clean', description: 'On the 1:30 x 6 Sets:3 Power Cleans',
              set_details: '[{"success":true,"load":135},{"success":true,"load":155},{"success":true,"load":165},' \
                           '{"success":true,"load":175},{"success":true,"load":175},{"success":true,"load":185}]' }

      result = SetSchemeExtractor.call(row)

      assert_equal Array.new(6) { |i| { reps: 3, load: [135, 155, 165, 175, 175, 185][i] } }, result
    end

    # "x 10" is interval structure ("10 rounds"), not a "sets: reps" scheme -- backtracking used
    # to split it into false captures "1" and "0", read as "1 set of 0 reps".
    test 'does not split a two-digit round count into a false "1 set of 0 reps" scheme' do
      row = { title: 'AFTER PARTY', description: 'On the Minute x 10 (5 Rounds): Front Squats',
              set_details: '[{"success":true,"load":145}]' }
      assert_equal [{ reps: 1, load: 145 }], SetSchemeExtractor.call(row)
    end
  end
end
