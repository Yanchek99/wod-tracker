require 'csv'

class SugarwodImport
  class CsvParser
    REQUIRED_HEADERS = %w[date title description best_result_raw best_result_display score_type barbell_lift notes].freeze

    class InvalidHeadersError < StandardError; end

    def self.call(file_content) = new(file_content).parse

    def initialize(file_content)
      @file_content = file_content
    end

    def parse
      table = CSV.parse(file_content, headers: true, encoding: 'utf-8')
      validate_headers!(table.headers)
      table.map(&:to_h)
    end

    private

    attr_reader :file_content

    def validate_headers!(headers)
      missing = REQUIRED_HEADERS - headers
      raise InvalidHeadersError, "missing required columns: #{missing.join(', ')}" if missing.any?
    end
  end
end
