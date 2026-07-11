namespace :workout_extraction do
  desc 'Parse raw WOD text into a Workout via the LLM parser and print it (does not persist)'
  task :parse, [:text] => :environment do |_task, args|
    abort 'Usage: bin/rails "workout_extraction:parse[TEXT]"' if args[:text].blank?

    workout = WorkoutExtraction::LlmParser.call(args[:text])
    pp workout
    pp workout.segments
    pp workout.exercises
  rescue WorkoutExtraction::LlmParser::ExtractionError => e
    abort "Extraction failed: #{e.message}"
  end
end
