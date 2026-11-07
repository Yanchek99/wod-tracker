# Rebuilds a user's heuristic AthleteCapability rows from their logs (issue #1981).
# Recompute-from-scratch: each rule turns the user's logged movement_logs into attribute hashes and
# the old heuristic rows are replaced in one transaction, so stale rows (e.g. a cannot_do that newer
# logs contradict) disappear without special handling. Rules never write.
class CapabilityEstimator
  MODEL_VERSION = 'heuristic-v1'.freeze
  EPLEY_REP_CAP = 10
  MIN_TOTAL_LOGS = 5
  TINY_SET = 1
  MIN_SUBSTITUTION_LOGS = 2

  # Everything a rule may read. movement_logs are preloaded so rules make no per-row queries.
  Samples = Data.define(:user, :movement_logs, :total_logs, :exercise_index) do
    # The exercise a movement log was recorded against.
    def exercise_for(movement_log) = exercise_index[movement_log.id]
  end

  RULES = [MaxEffort, Unbroken, Timed, CannotDo].freeze

  def self.call(user, rules: RULES)
    new(user, rules).call
  end

  def self.samples_for(user)
    movement_logs = MovementLog.joins(:log).where(logs: { user_id: user.id })
                               .includes(:movement, log: { workout: [:exercises, { segments: :exercises }] })
                               .order('logs.created_at', :id).to_a
    Samples.new(user:, movement_logs:, total_logs: user.logs.count, exercise_index: exercise_index(movement_logs))
  end

  # Movement logs are built from workout.exercises_for_log_recording in order, so position pairs a
  # movement log with the exercise it was recorded against.
  def self.exercise_index(movement_logs)
    exercises = Hash.new { |cache, workout| cache[workout] = workout.exercises_for_log_recording.to_a }
    movement_logs.group_by(&:log).each_with_object({}) do |(log, logs), index|
      exercises[log.workout].zip(logs).each { |exercise, movement_log| index[movement_log.id] = exercise if movement_log }
    end
  end

  def initialize(user, rules)
    @user = user
    @rules = rules
  end

  def call
    samples = self.class.samples_for(@user)
    rows = @rules.flat_map { |rule| rule.call(samples) }
    replace_heuristic_rows(rows, samples.movement_logs.map(&:movement).index_by(&:id))
    nil
  end

  private

  def replace_heuristic_rows(rows, movements)
    computed_at = Time.current
    attributes = rows.filter_map { |row| valid_attributes(row, movements, computed_at) }
    AthleteCapability.transaction do
      @user.athlete_capabilities.source_heuristic.delete_all
      # Every row was validated in memory by valid_attributes; insert_all! avoids a query per row.
      AthleteCapability.insert_all!(attributes) if attributes.any? # rubocop:disable Rails/SkipsModelValidations
    end
  end

  # One malformed row must never block the rest of the user's capabilities (or make every retry fail),
  # so rows are validated in memory and the invalid ones are skipped with a warning.
  def valid_attributes(row, movements, computed_at)
    capability = AthleteCapability.new(row.merge(user: @user, source: :heuristic, model_version: MODEL_VERSION, computed_at:))
    capability.movement = movements[row[:movement_id]] if movements.key?(row[:movement_id])
    return capability.attributes.except('id').merge('created_at' => computed_at, 'updated_at' => computed_at) if capability.valid?

    Rails.logger.warn("CapabilityEstimator skipped invalid row for user #{@user.id}: #{capability.errors.full_messages.to_sentence}")
    nil
  end
end
