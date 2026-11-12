# The RailsAdmin stimulus backfill form's params, read into a step, dates and flags, plus the
# counts a dry run reports instead of enqueueing anything.
class StimulusBackfillForm
  # CrossFit.com daily pages carry a Stimulus and Strategy section from about mid-December 2024
  # (probed 2026-11-12: 2024-12-04 has none, 2024-12-18 onward does).
  STIMULUS_ARCHIVE_START = Date.new(2024, 12, 1)

  attr_reader :step, :start_date, :end_date

  def initialize(params)
    @step = StimulusBackfillJob::STEPS.include?(params[:step]) ? params[:step] : 'run_all'
    @start_date = parse_date(params[:start_date])
    @end_date = parse_date(params[:end_date])
    @force = params[:force] == '1'
    @dry_run = params[:dry_run] == '1'
  end

  def dry_run? = @dry_run

  def force? = @force

  def job_options
    { start_date:, end_date:, force: force? }
  end

  # Human-readable lines describing what the chosen step would do.
  def dry_run_counts
    lines = []
    lines << "#{scrape_days} days to scrape" if scrape_days && %w[scrape run_all].include?(step)
    lines << "#{extract_count} workout(s) to extract" if %w[extract run_all].include?(step)
    lines << predict_summary if step == 'predict'
    lines
  end

  private

  def scrape_days
    (end_date - start_date).to_i + 1 if start_date && end_date && start_date <= end_date
  end

  def extract_count
    IntendedStimulusBackfill.targets(force: force?).count
  end

  def predict_summary
    result = StimulusLearner.call(dry_run: true)
    "#{result.workouts_written} workout(s) and #{result.exercises_written} movement(s) would get new predictions " \
      "(#{result.unchanged} unchanged)"
  end

  def parse_date(value)
    Date.iso8601(value.to_s) if value.present?
  rescue Date::Error
    nil
  end
end
