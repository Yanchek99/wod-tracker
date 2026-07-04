module CfWod
  # Named Hero/benchmark WODs commonly open with the workout's own name as its own paragraph
  # before the prescription (e.g. crossfit.com's "Ned"/"Adrian" pages). When that name exactly
  # matches an already-seeded Workout, there is no need to heuristically reconstruct it from
  # prose -- the existing, hand-curated definition is strictly more trustworthy than anything
  # the parser could rebuild, and reusing it sidesteps every parsing edge case entirely.
  class NamedWorkoutFinder
    def self.find(body_text) = new(body_text).find

    def initialize(body_text)
      @body_text = body_text
    end

    def find
      return nil if candidate.blank?

      Workout.find_by('lower(name) = ?', candidate.downcase)
    end

    private

    attr_reader :body_text

    def candidate
      body_text.to_s.split(/\n{2,}/).first&.strip
    end
  end
end
