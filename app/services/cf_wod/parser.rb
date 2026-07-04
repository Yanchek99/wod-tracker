module CfWod
  class Parser
    # No team_size detection in v1 -- just flag it for a human to add manually.
    PARTNER_OR_TEAM_MENTION = /\b(?:partner|team)\b/i

    def self.call(wod_page) = new(wod_page).parse

    def initialize(wod_page)
      @wod_page = wod_page
    end

    def parse
      return rest_day_result if wod_page.rest_day?

      named_workout = NamedWorkoutFinder.find(wod_page.body_text)
      return named_workout_result(named_workout) if named_workout

      format = FormatDetector.new(wod_page.body_text).detect
      workout = build_workout(format)
      reasons = collect_reasons(workout, format)
      workout.notes = assemble_notes

      finalize(workout, reasons)
    end

    private

    attr_reader :wod_page

    def rest_day_result
      ParseResult.new(workout: nil, status: :failed, reason: 'Rest day; no workout to parse', raw_text: wod_page.body_text)
    end

    # An existing, hand-curated Workout is a fully confident result -- there is nothing to
    # reconstruct or flag. Its notes are left untouched rather than overwritten with today's
    # scraped body text, since the seeded record is already the trusted source.
    def named_workout_result(workout)
      ParseResult.new(workout: workout, status: :parsed, reason: nil, raw_text: wod_page.body_text)
    end

    def collect_reasons(workout, format)
      reasons = BodyBuilder.new(workout, wod_page.body_text, format).build
      reasons << 'Could not determine workout format from body text' unless format.score_type
      reasons << 'Mentions a partner/team; team_size not detected' if wod_page.body_text.match?(PARTNER_OR_TEAM_MENTION)
      reasons
    end

    def build_workout(format)
      Workout.new(
        name: "CF-#{wod_page.slug}",
        score_type: format.score_type,
        time: format.time,
        rounds: format.rounds,
        interval: format.interval,
        time_cap_seconds: format.time_cap_seconds
      )
    end

    def assemble_notes
      sections = [wod_page.body_text]
      sections << "Stimulus and Strategy:\n#{wod_page.description}" if wod_page.description.present?
      sections << "Scaling:\n#{wod_page.scaling}" if wod_page.scaling.present?
      sections.join("\n\n")
    end

    def finalize(workout, reasons)
      has_parts = workout.exercises.any? || workout.segments.any?
      status = status_for(has_parts, reasons)

      ParseResult.new(
        workout: has_parts ? workout : nil,
        status: status,
        reason: reasons.any? ? reasons.uniq.join('; ') : nil,
        raw_text: wod_page.body_text
      )
    end

    def status_for(has_parts, reasons)
      return :failed unless has_parts
      return :partial if reasons.any?

      :parsed
    end
  end
end
