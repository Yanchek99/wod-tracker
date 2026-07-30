require 'test_helper'

class SugarwodImport
  class BarbellLiftHeaderTest < ActiveSupport::TestCase
    test 'defaults to a single rep when the description says "Build to Heavy Single"' do
      row = { title: 'Hang Squat Clean', description: 'Build to Heavy Single', barbell_lift: 'Hang Squat Clean' }
      assert_equal 'Find a 1-rep-max Hang Squat Clean', BarbellLiftHeader.call(row)
    end

    test 'extracts the rep count from "Set of N" in the description' do
      row = { title: 'Bench Press', description: 'Build to Heavy Set of 3', barbell_lift: 'Bench Press' }
      assert_equal 'Find a 3-rep-max Bench Press', BarbellLiftHeader.call(row)
    end

    test 'extracts the rep count from an "AxB" scheme in the title' do
      row = { title: 'Back Squat 3x5', description: 'Back Squat for load: #1: 5 reps #2: 5 reps #3: 5 reps',
              barbell_lift: 'Back Squat' }
      assert_equal 'Find a 5-rep-max Back Squat', BarbellLiftHeader.call(row)
    end

    test 'defaults to 1 rep when no rep count can be determined' do
      row = { title: 'Deadlift', description: 'Build to a heavy deadlift for the day', barbell_lift: 'Deadlift' }
      assert_equal 'Find a 1-rep-max Deadlift', BarbellLiftHeader.call(row)
    end
  end
end
