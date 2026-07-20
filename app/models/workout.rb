class Workout < ApplicationRecord
  include WorkoutFingerprint
  include WorkoutPositionReservation
  include WorkoutScoring

  has_many :segments, dependent: :destroy
  has_many :exercises, through: :segments
  has_many :movements, through: :exercises
  has_many :logs, dependent: :destroy
  has_many :movement_logs, through: :logs
  has_many :schedules, dependent: :destroy
  has_many :programs, through: :schedules
  has_rich_text :notes

  accepts_nested_attributes_for :segments, allow_destroy: true

  enum :score_type, Metric.measurements, prefix: :score

  validates :name, :score_type, presence: true
  validates :ladder_step,
            numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :team_size,
            numericality: { only_integer: true, greater_than: 1 }, allow_nil: true

  def self.search_by_name(name)
    return all unless name

    query = name.split.reduce(nil) do |q, word|
      q.nil? ? arel_table[:name].matches("%#{word}%") : q.and(arel_table[:name].matches("%#{word}%"))
    end
    where(query)
  end

  # The one segment that determines the workout's overall scheme: the sole segment when there's
  # exactly one, or the sole schemed one when there are several but only one carries an actual
  # scheme. nil when no single segment dominates (a genuine multi-part chipper).
  #
  # Segments are loaded into an Array before checking one?/many? here: CollectionProxy#one?/
  # #many?/#count run a SQL query rather than counting the in-memory target, which returns 0 for
  # an unsaved workout with only just-built (unpersisted) segments -- e.g. CfWod::WorkoutParser's
  # freshly parsed, not-yet-saved Workout. Array#one?/#many? don't have that problem.
  def governing_segment
    parts = segments.to_a
    return parts.sole if parts.one?

    schemed = parts.select(&:schemed?)
    schemed.sole if schemed.one?
  end

  def rounds_for_time?
    return governing_segment.rounds? || !governing_segment.schemed? if governing_segment

    segments.to_a.many? && !segmented_total_reps?
  end

  def amrap?
    governing_segment&.amrap? || false
  end

  # An open-ended ascending-rep ladder: each round's reps start at the participating exercise's own
  # reps and grow by ladder_step (on that exercise's cadence) until the clock runs out. Scored by
  # total reps. Independent of amrap?: most are time-capped AMRAPs, but some (e.g. the every-N-minute
  # ascents) carry no single time and live only through this flag.
  def ascending_ladder?
    ladder_step.present?
  end

  # A shared clock split across contiguous, labeled time-block segments (e.g. "0:00-5:00: row",
  # "5:00-10:00: bike"), where every segment carries its own time slice and none of them
  # individually represents the whole clock. Distinct from governing_segment, which only fits
  # shapes where one segment sets the pace for the others.
  def segmented_total_reps?
    score_measurement == 'rep' && segments.to_a.many? && segments.all? { |segment| segment.time_seconds.present? }
  end

  def emom?
    governing_segment&.emom? || false
  end

  def timed_rounds?
    governing_segment&.timed_rounds? || false
  end

  def interval?
    governing_segment&.interval? || false
  end

  # Work is shared across multiple athletes (a partner or team workout). team_size
  # is the number of athletes; nil is an ordinary individual workout.
  def team?
    team_size.present?
  end

  def partner?
    team_size == 2
  end

  def logged?(user)
    logs.where(user)
  end

  def reps_from_interval
    governing_segment&.reps_from_interval
  end

  def score_measurement
    score_type
  end

  # Time cap that formats the seconds DB value to "Minutes:Seconds"
  def time_cap
    return nil if time_cap_seconds.nil?

    duration = ActiveSupport::Duration.build(time_cap_seconds).parts
    format '%<minutes>02d:%<seconds>02d', minutes: duration.fetch(:minutes, 0), seconds: duration.fetch(:seconds, 0)
  end

  # Time cap is a string in the format "Minutes:Seconds"
  def time_cap=(time_cap)
    if time_cap.include? ':'
      minutes, seconds = time_cap.split(':', 2)
      time_in_seconds = (minutes.to_i.minute + seconds.to_i.second).second
      self.time_cap_seconds = time_in_seconds
    else
      self.time_cap_seconds = time_cap
    end
  end

  # Replaces this workout's attributes and every segment/exercise with the equivalent data from a
  # freshly LlmParser-built (unsaved) workout, entirely in memory -- nothing persists until the
  # caller saves. Full replace, not merge: re-pasting text redefines the whole workout, matching
  # how WorkoutExtraction::LlmParser already behaves for a brand-new workout.
  def replace_with_extraction!(extracted)
    assign_attributes(
      name: extracted.name, notes: extracted.notes.to_s, score_type: extracted.score_type,
      time_cap_seconds: extracted.time_cap_seconds, ladder_step: extracted.ladder_step,
      team_size: extracted.team_size
    )
    segments.each(&:mark_for_destruction)
    self.segments_attributes = extracted.segments.map { |segment| segment_attributes_for(segment) }
  end

  private

  def segment_attributes_for(segment)
    segment.attributes.except('id', 'workout_id', 'position', 'created_at', 'updated_at')
           .merge('exercises_attributes' => segment.exercises.map { |exercise| exercise_attributes_for(exercise) })
  end

  def exercise_attributes_for(exercise)
    exercise.attributes.except('id', 'segment_id', 'created_at', 'updated_at')
  end
end
