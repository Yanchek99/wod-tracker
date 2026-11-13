namespace :stimulus do
  desc 'Print draft claims (YAML) for workouts with CrossFit stimulus text that config/stimulus_claims.yml lacks'
  task propose_claims: :environment do
    claimed = StimulusClaims.load.map(&:workout_name)
    drafts = Workout.where.not(intended_stimulus_notes: [nil, '']).where.not(name: claimed)
                    .includes(segments: { exercises: :movement }).order(:id).map do |workout|
      movements = workout.segments.flat_map(&:exercises).map { |exercise| exercise.movement.name }
      { 'workout' => workout.name, 'reviewed' => 'draft -- check against the text',
        'claims' => StimulusClaims.propose(workout.intended_stimulus_notes, movements) }
    end
    puts drafts.to_yaml(line_width: 110)
  end

  desc 'Compare calculated stimulus against the claims in config/stimulus_claims.yml'
  task accuracy: :environment do
    puts StimulusAccuracy.summary(StimulusAccuracy.call)
  end
end
