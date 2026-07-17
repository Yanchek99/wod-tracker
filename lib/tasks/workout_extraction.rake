namespace :workout_extraction do
  desc 'Parse workout text (paste it in, then press Ctrl-D) into a Workout via the LLM parser and print it (does not persist)'
  task parse: :environment do
    puts 'Paste the workout text below, then press Ctrl-D (Ctrl-Z on Windows) when done:'
    text = $stdin.read
    abort 'No text given' if text.blank?

    workout = WorkoutExtraction::LlmParser.call(text, date: Date.current, logger: Logger.new($stdout))
    pp workout
    pp workout.segments
    # workout.exercises (has_many :through :segments) stays empty in memory on an unsaved workout --
    # read exercises via each segment instead.
    pp workout.segments.flat_map(&:exercises)
  rescue WorkoutExtraction::LlmParser::ExtractionError => e
    abort "Extraction failed: #{e.message}"
  rescue WorkoutExtraction::LlmParser::UnrepresentableWorkoutError => e
    abort "Not extractable: #{e.message}"
  end
end
