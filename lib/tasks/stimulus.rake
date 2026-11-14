namespace :stimulus do
  desc 'Print draft claims (YAML) for workouts with CrossFit stimulus text that config/stimulus_claims.yml lacks'
  task propose_claims: :environment do
    claimed = StimulusClaims.load.map(&:workout_name)
    drafts = Workout.where.not(intended_stimulus_notes: [nil, '']).where.not(name: claimed)
                    .includes(segments: { exercises: :movement }).order(:id).map do |workout|
      movements = workout.segments.flat_map(&:exercises).map { |exercise| exercise.movement.name }
      { 'workout' => workout.name, 'source' => 'crossfit_text', 'reviewed' => 'draft -- check against the text',
        'claims' => StimulusClaims.propose(workout.intended_stimulus_notes, movements) }
    end
    puts drafts.to_yaml(line_width: 110)
  end

  desc "Refresh Open claims in config/stimulus_claims.yml from the public leaderboard (men's Rx 80th-95th pct)"
  task :open_leaderboard_claims, [:years] => :environment do |_task, args|
    years = args[:years].present? ? args[:years].split(/[ ;]/).map(&:to_i) : OpenLeaderboard::COLUMNS.keys
    fresh = OpenLeaderboard.claim_entries(years, client: OpenLeaderboard::Client.new) do |name, claim|
      puts "#{name}: #{claim ? claim['result'].inspect : 'skipped (load-scored or no Rx scores)'}"
    end
    # Replace only the refreshed years' Open claims; every other claim stays as it is.
    prefixes = years.map { |year| "Open #{year.to_s[2..]}." }
    kept = StimulusClaims.entries.reject do |entry|
      entry['source'] == 'open_leaderboard' && entry['workout'].start_with?(*prefixes)
    end
    StimulusClaims.write(kept + fresh)
    puts "Wrote #{fresh.size} Open claim(s)."
  end

  desc 'Compare calculated stimulus against the claims in config/stimulus_claims.yml'
  task accuracy: :environment do
    puts StimulusAccuracy.summary(StimulusAccuracy.call)
  end
end
