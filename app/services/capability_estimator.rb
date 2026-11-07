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
  Samples = Data.define(:user, :movement_logs, :total_logs)

  RULES = [MaxEffort, Unbroken, Timed].freeze

  def self.call(user, rules: RULES)
    new(user, rules).call
  end

  def self.samples_for(user)
    movement_logs = MovementLog.joins(:log).where(logs: { user_id: user.id })
                               .includes(:movement, log: { workout: :segments })
                               .order('logs.created_at', :id).to_a
    Samples.new(user:, movement_logs:, total_logs: user.logs.count)
  end

  def initialize(user, rules)
    @user = user
    @rules = rules
  end

  def call
    samples = self.class.samples_for(@user)
    rows = @rules.flat_map { |rule| rule.call(samples) }
    replace_heuristic_rows(rows)
    nil
  end

  private

  def replace_heuristic_rows(rows)
    computed_at = Time.current
    AthleteCapability.transaction do
      @user.athlete_capabilities.source_heuristic.delete_all
      rows.each do |row|
        @user.athlete_capabilities.create!(row.merge(source: :heuristic, model_version: MODEL_VERSION, computed_at:))
      end
    end
  end
end
