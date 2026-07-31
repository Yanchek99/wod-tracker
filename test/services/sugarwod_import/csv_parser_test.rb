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

    test 'parses a valid CSV prefixed with a UTF-8 BOM' do
      rows = CsvParser.call("﻿#{VALID_CSV}")

      assert_equal 1, rows.size
      assert_equal 'Fran', rows.first['title']
    end

    test 'parses a real BOM-prefixed upload read as ASCII-8BIT, as Rack delivers it' do
      rows = CsvParser.call(binary_upload_content("﻿#{VALID_CSV}"))

      assert_equal 1, rows.size
      assert_equal 'Fran', rows.first['title']
    end

    test 'parses a real upload containing non-ASCII bytes (e.g. a bullet separator) read as ASCII-8BIT' do
      csv = "date,title,description,best_result_raw,best_result_display,score_type,barbell_lift,notes\n" \
            "01/02/2018,Fran,Thruster•Pull-ups,378,6:18,,,\n"

      rows = CsvParser.call(binary_upload_content(csv))

      assert_equal 1, rows.size
      assert_equal 'Thruster•Pull-ups', rows.first['description']
    end

    test 'replaces genuinely invalid byte sequences with a visible marker instead of silently dropping them' do
      csv = "date,title,description,best_result_raw,best_result_display,score_type,barbell_lift,notes\n" \
            "01/02/2018,Fran,caf\xE9 diner,378,6:18,,,\n"

      rows = CsvParser.call(binary_upload_content(csv))

      assert_equal 1, rows.size
      assert_equal 'caf� diner', rows.first['description']
    end

    private

    def binary_upload_content(csv_text)
      tempfile = Tempfile.new('upload')
      tempfile.binmode
      tempfile.write(csv_text)
      tempfile.rewind
      ActionDispatch::Http::UploadedFile.new(tempfile: tempfile, filename: 'upload.csv', type: 'text/csv').read
    end
  end
end
