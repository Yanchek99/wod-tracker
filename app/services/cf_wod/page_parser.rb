module CfWod
  class PageParser
    # Matched case-insensitively against each paragraph's leading <strong> text. Some workouts
    # (e.g. crossfit.com/260620) go straight from the description into "Intermediate option"/
    # "Beginner option" paragraphs with no separate "Scaling" heading at all.
    SECTION_MARKERS = {
      'Stimulus and Strategy' => :description,
      'Scaling' => :scaling,
      'Intermediate Option' => :scaling,
      'Beginner Option' => :scaling,
      'Related' => :ignore,
      'Resources' => :ignore,
      'Find a gym near you' => :ignore
    }.freeze

    def initialize(date, html)
      @date = date
      @html = html
      @doc = Nokogiri::HTML(html)
    end

    def parse
      container = wod_container
      raise Fetcher::UnrecognizedTemplateError, 'Unrecognized page template' unless container

      build_wod_page(container, bucket_paragraphs(container.css('p')))
    end

    private

    attr_reader :date, :html, :doc

    def build_wod_page(container, buckets)
      WodPage.new(
        date: date,
        slug: date.strftime('%y%m%d'),
        title: extract_title,
        body_html: html_of(buckets[:body]),
        body_text: text_of(buckets[:body]),
        description: text_of(buckets[:description]),
        scaling: text_of(buckets[:scaling]),
        rest_day: rest_day?(container),
        previous_slug: extract_slug('previousUrl', 'prev'),
        next_slug: extract_slug('nextUrl', 'next')
      )
    end

    def wod_container
      doc.at_css('article span[class*="_text-block"]') || doc.at_css('div.wod.active div.content')
    end

    def bucket_paragraphs(paragraphs)
      buckets = Hash.new { |hash, key| hash[key] = [] }
      current = :body

      paragraphs.each do |paragraph|
        heading = paragraph.at_css('strong')&.text
        heading = heading.strip.downcase if heading
        marker = SECTION_MARKERS.find { |prefix, _| heading&.start_with?(prefix.downcase) }
        current = marker.last if marker
        buckets[current] << paragraph
      end

      buckets
    end

    def text_of(nodes)
      nodes.map { |node| node.text.strip }.join("\n\n").presence
    end

    def html_of(nodes)
      nodes.map(&:to_html).join.presence
    end

    def rest_day?(container)
      container.text.match?(/\brest\s+day\b/i)
    end

    def extract_title
      doc.at_css('title')&.text&.delete_prefix('CrossFit | ')
    end

    def extract_slug(preloaded_key, legacy_direction)
      preloaded_slug(preloaded_key) || legacy_nav_slug(legacy_direction)
    end

    def preloaded_slug(key)
      PreloadedState.parse(html)&.dig('pages', key)&.delete_prefix('/')
    end

    def legacy_nav_slug(direction)
      href = doc.at_css("a.#{direction}")&.[]('href')
      match = href&.match(%r{/workout/(\d{4})/(\d{2})/(\d{2})})
      Date.new(*match.captures.map(&:to_i)).strftime('%y%m%d') if match
    end
  end
end
