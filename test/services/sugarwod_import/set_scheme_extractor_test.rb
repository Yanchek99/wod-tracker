require 'test_helper'

class SugarwodImport
  class SetSchemeExtractorTest < ActiveSupport::TestCase
    test 'extracts a varying pyramid scheme, matching each rep count to its set position' do
      row = { title: 'Front Squat 3-1-3-1-3-1-12', description: '',
              set_details: '[{"success":true,"load":155},{"success":true,"load":165},{"success":true,"load":155},' \
                           '{"success":true,"load":175},{"success":true,"load":155},{"success":true,"load":185},' \
                           '{"success":true,"load":125}]' }

      result = SetSchemeExtractor.call(row)

      assert_equal [{ reps: 3, load: 155 }, { reps: 1, load: 165 }, { reps: 3, load: 155 }, { reps: 1, load: 175 },
                    { reps: 3, load: 155 }, { reps: 1, load: 185 }, { reps: 12, load: 125 }], result
    end

    test 'drops failed sets and keeps positional alignment with the successful ones' do
      row = { title: 'Power Clean 1-1-1-1-1', description: '',
              set_details: '[{"success":true,"load":175},{"success":true,"load":185},{"success":true,"load":205},' \
                           '{"success":true,"load":215},{"success":false,"load":225}]' }

      result = SetSchemeExtractor.call(row)

      assert_equal [{ reps: 1, load: 175 }, { reps: 1, load: 185 }, { reps: 1, load: 205 }, { reps: 1, load: 215 }],
                   result
    end

    test 'applies a uniform "AxB" title scheme to every set when the set count matches A' do
      row = { title: 'Back Squat 3x5', description: 'Back Squat for load: #1: 5 reps #2: 5 reps #3: 5 reps',
              set_details: '[{"success":true,"load":200},{"success":true,"load":205},{"success":true,"load":205}]' }

      result = SetSchemeExtractor.call(row)

      assert_equal [{ reps: 5, load: 200 }, { reps: 5, load: 205 }, { reps: 5, load: 205 }], result
    end

    test 'applies a uniform "Set of N" description scheme to every successful set' do
      row = { title: 'Bench Press', description: 'Build to Heavy Set of 3',
              set_details: '[{"success":true,"load":150},{"success":true,"load":165}]' }

      result = SetSchemeExtractor.call(row)

      assert_equal [{ reps: 3, load: 150 }, { reps: 3, load: 165 }], result
    end

    test 'defaults to 1 rep only when there is exactly one successful set and no scheme text' do
      row = { title: 'Deadlift', description: 'Build to a heavy deadlift for the day',
              set_details: '[{"success":true,"load":315}]' }

      result = SetSchemeExtractor.call(row)

      assert_equal [{ reps: 1, load: 315 }], result
    end

    test 'returns nil rather than defaulting to 1 rep for multiple sets with no recognizable scheme' do
      row = { title: 'Deadlift', description: 'Build to a heavy deadlift for the day',
              set_details: '[{"success":true,"load":275},{"success":true,"load":315}]' }

      assert_nil SetSchemeExtractor.call(row)
    end

    test 'returns nil when the dash-scheme length does not match set_details length' do
      row = { title: 'Bench Press 4-2-4-2-4', description: '',
              set_details: '[{"success":true,"load":155},{"success":true,"load":185},{"success":true,"load":155},' \
                           '{"success":true,"load":195},{"success":true,"load":155},{"success":true,"load":205}]' }

      assert_nil SetSchemeExtractor.call(row)
    end

    test 'returns nil when set_details is blank' do
      assert_nil SetSchemeExtractor.call({ title: 'Deadlift', description: '', set_details: '' })
      assert_nil SetSchemeExtractor.call({ title: 'Deadlift', description: '', set_details: nil })
    end

    test 'returns nil when set_details fails to parse as JSON' do
      assert_nil SetSchemeExtractor.call({ title: 'Deadlift', description: '', set_details: 'not json' })
    end

    test 'returns nil when every set failed' do
      row = { title: 'Deadlift', description: '', set_details: '[{"success":false,"load":315}]' }

      assert_nil SetSchemeExtractor.call(row)
    end

    test 'returns nil rather than fabricating a zero load for a successful set with a missing load' do
      row = { title: 'Deadlift', description: 'Build to a heavy deadlift for the day',
              set_details: '[{"success":true,"load":null}]' }

      assert_nil SetSchemeExtractor.call(row)
    end

    test 'returns nil rather than fabricating a zero load for a successful set with a blank load' do
      row = { title: 'Deadlift', description: 'Build to a heavy deadlift for the day',
              set_details: '[{"success":true,"load":""}]' }

      assert_nil SetSchemeExtractor.call(row)
    end

    test 'returns nil for the whole scheme when any successful set in a pyramid has no load' do
      row = { title: 'Front Squat 3-1-3', description: '',
              set_details: '[{"success":true,"load":155},{"success":true,"load":null},{"success":true,"load":175}]' }

      assert_nil SetSchemeExtractor.call(row)
    end

    test 'does not mistake a non-numeric dash phrase in a movement name for a rep scheme' do
      row = { title: '3-Position Power Snatch', description: 'Build to a heavy single',
              set_details: '[{"success":true,"load":135}]' }

      result = SetSchemeExtractor.call(row)

      assert_equal [{ reps: 1, load: 135 }], result
    end

    test 'strips a trailing rest/coaching note before applying the dash scheme' do
      row = { title: 'Bench Press', description: '4-2-4-2-4-2Rest As Needed Between Sets.',
              set_details: '[{"success":true,"load":155},{"success":true,"load":185},{"success":true,"load":155},' \
                           '{"success":true,"load":195},{"success":true,"load":155},{"success":true,"load":205}]' }

      result = SetSchemeExtractor.call(row)

      assert_equal [{ reps: 4, load: 155 }, { reps: 2, load: 185 }, { reps: 4, load: 155 }, { reps: 2, load: 195 },
                    { reps: 4, load: 155 }, { reps: 2, load: 205 }], result
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

    test 'expands a repeating "Wave #N" scheme to its flattened set-by-set rep sequence' do
      description = 'Back Squat WavesWave #1: 7 Back Squats 5 Back Squats 3 Back Squats Wave #2: 7 Back Squats 5 ' \
                    'Back Squats 3 Back Squats Wave #3: 7 Back Squats 5 Back Squats 3 Back Squats Rest As Needed ' \
                    'Between Sets. Increase Loads Slightly With Each Wave.'
      loads = [150, 165, 175, 165, 175, 185, 175, 185, 200]
      row = { title: 'Back Squat Waves', description: description,
              set_details: loads.map { |load| { success: true, load: load } }.to_json }

      assert_equal ([7, 5, 3] * 3).zip(loads).map { |reps, load| { reps: reps, load: load } }, SetSchemeExtractor.call(row)
    end
  end
end
