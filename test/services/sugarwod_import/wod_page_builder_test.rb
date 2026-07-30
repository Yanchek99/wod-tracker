require 'test_helper'

class SugarwodImport
  class WodPageBuilderTest < ActiveSupport::TestCase
    test 'splits bullet-separated description into newline-separated body_text lines' do
      row = { title: 'Fran', description: '21-15-9 reps for time of:• Thruster 95/65#• Pull-ups' }
      page = WodPageBuilder.call(row, date: Date.new(2018, 1, 1))
      assert_equal "Fran\n21-15-9 reps for time of:\nThruster 95/65#\nPull-ups", page.body_text
    end

    test 'splits Men:/Women: prescription text onto its own line even when run on from the prior line' do
      row = { title: '18.Zero',
              description: '21-15-9 reps for time of:•Dumbbell snatches•BurpeesMen: 50-lb. dumbbellWomen: 35-lb. dumbbell' }
      page = WodPageBuilder.call(row, date: Date.new(2018, 1, 1))
      assert_includes page.body_text, "\nMen: 50-lb. dumbbell"
      assert_includes page.body_text, "\nWomen: 35-lb. dumbbell"
    end

    test 'sets date and a slug derived from the date and title' do
      row = { title: 'Fran', description: 'For time:' }
      page = WodPageBuilder.call(row, date: Date.new(2018, 1, 2))
      assert_equal Date.new(2018, 1, 2), page.date
      assert_match(/\Asw-180102-[0-9a-f]{8}\z/, page.slug)
    end
  end
end
