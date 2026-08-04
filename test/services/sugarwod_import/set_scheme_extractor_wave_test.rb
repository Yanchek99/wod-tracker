require 'test_helper'

# Coverage for rep-scheme shapes split out of set_scheme_extractor_test.rb (which covers the
# other rep-scheme shapes) to keep that class within Metrics/ClassLength: the repeating
# "Wave #N: A B C reps..." shape (e.g. 3 waves of 7-5-3 reps = 9 total sets), the labeled
# "Set N: X reps" shape with no percentages, the "X Reps @ Y%" percentage-labeled shape, plus
# the plural "Sets of N" phrasing and the default_single_set_scheme unrecognized-signal guard.
class SugarwodImport
  class SetSchemeExtractorWaveTest < ActiveSupport::TestCase
    test 'expands a repeating "Wave #N" scheme to its flattened set-by-set rep sequence' do
      description = 'Back Squat WavesWave #1: 7 Back Squats 5 Back Squats 3 Back Squats Wave #2: 7 Back Squats 5 ' \
                    'Back Squats 3 Back Squats Wave #3: 7 Back Squats 5 Back Squats 3 Back Squats Rest As Needed ' \
                    'Between Sets. Increase Loads Slightly With Each Wave.'
      loads = [150, 165, 175, 165, 175, 185, 175, 185, 200]
      row = { title: 'Back Squat Waves', description: description,
              set_details: loads.map { |load| { success: true, load: load } }.to_json }

      assert_equal ([7, 5, 3] * 3).zip(loads).map { |reps, load| { reps: reps, load: load } }, SetSchemeExtractor.call(row)
    end

    test 'extracts a rep scheme from "Set N: X <movement>" labels with no percentages' do
      row = { title: 'Back Squat',
              description: 'On the 2:30 x 5 Sets: Set 1: 10 Back Squats Set 2: 8 Back Squats Set 3: 6 Back Squats ' \
                           'Set 4: 4 Back Squats Set 5: 2 Back Squats',
              set_details: '[{"success":true,"load":145},{"success":true,"load":165},{"success":true,"load":185},' \
                           '{"success":true,"load":205},{"success":true,"load":225}]' }

      result = SetSchemeExtractor.call(row)

      expected_reps = [10, 8, 6, 4, 2]
      expected_loads = [145, 165, 185, 205, 225]
      assert_equal expected_reps.zip(expected_loads).map { |reps, load| { reps: reps, load: load } }, result
    end

    test 'extracts a rep scheme from unlabeled "X Reps @ Y%" fragments' do
      row = { title: 'AFTER PARTY',
              description: 'Back Squat10 Reps @ 67% 1RM8 Reps @ 74% 1RM6 Reps @ 80% 1RM4 Reps @ 85% 1RM2 Reps @ 90% ' \
                           '1RMRest 3 Minutes Between Sets',
              set_details: '[{"success":true,"load":"170"},{"success":true,"load":"185"},{"success":true,"load":"200"},' \
                           '{"success":true,"load":"215"},{"success":true,"load":"225"}]' }

      result = SetSchemeExtractor.call(row)

      expected_reps = [10, 8, 6, 4, 2]
      expected_loads = [170, 185, 200, 215, 225]
      assert_equal expected_reps.zip(expected_loads).map { |reps, load| { reps: reps, load: load } }, result
    end

    test 'extracts a rep scheme from unlabeled percentage fragments with no "Set" word at all' do
      row = { title: 'Squat Snatch',
              description: '[All Percentages Based Off 1RM Snatch] 3 Reps @ 40% 3 Reps @ 50% 3 Reps @ 60% ' \
                           '3 Reps @ 75% 2 Reps @ 80%1 Rep @ 85%1 Rep @ 85% Rest 1-3 Minutes Between All Sets',
              set_details: '[{"success":true,"load":65},{"success":true,"load":85},{"success":true,"load":105},' \
                           '{"success":true,"load":130},{"success":true,"load":135},{"success":true,"load":145},' \
                           '{"success":true,"load":145}]' }

      result = SetSchemeExtractor.call(row)

      expected_reps = [3, 3, 3, 3, 2, 1, 1]
      expected_loads = [65, 85, 105, 130, 135, 145, 145]
      assert_equal expected_reps.zip(expected_loads).map { |reps, load| { reps: reps, load: load } }, result
    end

    test 'applies a "Sets of N" (plural) description scheme instead of falling back to a 1-rep default' do
      row = { title: 'Back Squat', description: 'For Total Load: 5 Sets of 5',
              set_details: '[{"success":true,"load":225}]' }

      result = SetSchemeExtractor.call(row)

      assert_equal [{ reps: 5, load: 225 }], result
    end

    test 'returns nil rather than defaulting to 1 rep when a single-set description has an unparsed scheme signal' do
      row = { title: 'Deadlift', description: 'Build to a heavy deadlift, 3 sets total',
              set_details: '[{"success":true,"load":315}]' }

      assert_nil SetSchemeExtractor.call(row)
    end

    test 'matches the full dash scheme when coaching-note text is glued directly onto it with no space' do
      row = { title: 'Back Squat',
              description: '6 Sets:6-6-5-5-4-4All Sets Based on 1RM Back SquatSet 1-2: 8 @ 70% Set 3-4: 6 @ 75% ' \
                           'Set 5-6: 4 @ 80%',
              set_details: '[{"success":true,"load":175},{"success":true,"load":175},{"success":true,"load":185},' \
                           '{"success":true,"load":185},{"success":true,"load":200},{"success":true,"load":200}]' }

      result = SetSchemeExtractor.call(row)

      expected_reps = [6, 6, 5, 5, 4, 4]
      expected_loads = [175, 175, 185, 185, 200, 200]
      assert_equal expected_reps.zip(expected_loads).map { |reps, load| { reps: reps, load: load } }, result
    end
  end
end
