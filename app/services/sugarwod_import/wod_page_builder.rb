class SugarwodImport
  class WodPageBuilder
    PRESCRIPTION_MARKER = /(Men:|Women:|Male:|Female:)/

    def self.call(row, date:) = new(row, date: date).build

    def initialize(row, date:)
      @row = row
      @date = date
    end

    def build
      CfWod::WodPage.new(
        date: date, slug: slug, title: title, body_html: nil, body_text: body_text,
        description: row[:description], scaling: nil, rest_day: false,
        previous_slug: nil, next_slug: nil
      )
    end

    private

    attr_reader :row, :date

    def title
      row[:title].to_s.strip
    end

    def slug
      "sw-#{date.strftime('%y%m%d')}-#{Digest::SHA256.hexdigest(title)[0, 8]}"
    end

    def body_text
      ([title] + description_lines).join("\n")
    end

    def description_lines
      row[:description].to_s
                       .tr('•', "\n")
                       .gsub(PRESCRIPTION_MARKER, "\n\\1")
                       .split("\n")
                       .map(&:strip)
                       .reject(&:empty?)
    end
  end
end
