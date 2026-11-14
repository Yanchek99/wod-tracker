# The RailsAdmin stimulus tools form: which step to run and whether it is a dry run, plus the
# summary a dry run shows and the message a real run flashes.
class StimulusToolsForm
  STEPS = %w[recalculate fetch_text accuracy].freeze

  attr_reader :step

  def initialize(params)
    @step = STEPS.include?(params[:step]) ? params[:step] : STEPS.first
    @dry_run = params[:dry_run] == '1'
  end

  def dry_run? = @dry_run

  # The accuracy report only reads, so it always renders in place.
  def renders_in_place? = dry_run? || step == 'accuracy'

  def dry_run_summary
    case step
    when 'recalculate'
      result = StimulusRecalculation.call(dry_run: true)
      "#{result.workouts_written} workout(s) and #{result.exercises_written} movement(s) would get new calculated " \
        "values (#{result.unchanged} unchanged, #{result.retired} retired)"
    when 'fetch_text'
      "#{StimulusTextFetch.call(dry_run: true)} existing workout(s) would have CrossFit's text fetched"
    when 'accuracy'
      StimulusAccuracy.summary(StimulusAccuracy.call).join("\n")
    end
  end

  def run
    case step
    when 'recalculate'
      RecalculateStimulusJob.perform_later
      'Queued a stimulus recalculation.'
    when 'fetch_text'
      "Queued CrossFit text fetches for #{StimulusTextFetch.call} existing workout(s)."
    end
  end
end
