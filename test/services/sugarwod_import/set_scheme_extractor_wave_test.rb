require 'test_helper'

# Coverage for the repeating "Wave #N: A B C reps..." rep-scheme shape (e.g. 3 waves of 7-5-3
# reps = 9 total sets). Split out from set_scheme_extractor_test.rb (which covers the other rep-
# scheme shapes) to keep that class within Metrics/ClassLength.
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
  end
end
