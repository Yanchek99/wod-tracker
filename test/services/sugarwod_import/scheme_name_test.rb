require 'test_helper'

class SugarwodImport
  class SchemeNameTest < ActiveSupport::TestCase
    test 'uses "1xM" notation for a single set, not a bare, ambiguous number' do
      sets = [{ reps: 5, load: 225 }]

      assert_equal 'Back Squat 1x5', SchemeName.call(movements(:back_squat), sets)
    end

    test 'uses "NxM" notation when every set has the same reps' do
      sets = Array.new(7) { { reps: 2, load: 175 } }

      assert_equal 'Shoulder Press 7x2', SchemeName.call(movements(:shoulder_press), sets)
    end

    test 'falls back to the dash-joined scheme when reps actually vary between sets' do
      sets = [{ reps: 3, load: 155 }, { reps: 1, load: 165 }, { reps: 3, load: 155 }, { reps: 1, load: 175 },
              { reps: 3, load: 155 }, { reps: 1, load: 185 }, { reps: 12, load: 125 }]

      assert_equal 'Front Squat 3-1-3-1-3-1-12', SchemeName.call(movements(:front_squat), sets)
    end
  end
end
