# Queues FetchStimulusTextJob for every workout the app already scheduled from Crossfit.com that
# has no Stimulus and Strategy text yet, staggered so crossfit.com isn't hammered. Existing
# workouts only: nothing here imports or parses.
class StimulusTextFetch
  def self.targets
    Schedule.joins(:program, :workout)
            .where(programs: { name: 'Crossfit.com' })
            .where(workouts: { intended_stimulus_notes: [nil, ''] })
            .order(:posted_at)
  end

  # The number of workouts targeted.
  def self.call(dry_run: false)
    ids = targets.pluck(:id)
    return ids.size if dry_run

    ids.each_with_index do |id, i|
      FetchStimulusTextJob.set(wait: i * BackfillCrossfitWodsJob::DELAY_BETWEEN_REQUESTS).perform_later(id)
    end
    ids.size
  end
end
