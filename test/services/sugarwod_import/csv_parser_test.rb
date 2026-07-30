require 'test_helper'

class SugarwodImport
  class CsvParserTest < ActiveSupport::TestCase
    VALID_CSV = "date,title,description,best_result_raw,best_result_display,score_type,barbell_lift,notes\n" \
                "01/02/2018,Fran,21-15-9 reps for time of:,378,6:18,,,\n".freeze

    test 'parses rows into an array of hashes keyed by header' do
      rows = CsvParser.call(VALID_CSV)
      assert_equal 1, rows.size
      assert_equal 'Fran', rows.first['title']
      assert_equal '378', rows.first['best_result_raw']
    end

    test 'raises InvalidHeadersError when a required column is missing' do
      csv = "date,title\n01/02/2018,Fran\n"
      error = assert_raises(CsvParser::InvalidHeadersError) { CsvParser.call(csv) }
      assert_match(/description/, error.message)
    end
  end
end
