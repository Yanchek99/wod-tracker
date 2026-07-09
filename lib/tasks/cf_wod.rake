namespace :cf_wod do
  desc "Fetch and parse a single day's WOD from crossfit.com and print it (does not persist)"
  task :fetch, [:date] => :environment do |_task, args|
    abort 'Usage: bin/rails "cf_wod:fetch[YYYY-MM-DD]"' if args[:date].blank?

    page = CfWod::Fetcher.call(Date.parse(args[:date]))
    pp page

    workout = CfWod::WorkoutParser.call(page)
    pp workout
    pp workout.segments
    pp workout.exercises
  rescue CfWod::Fetcher::FetchError => e
    abort "Fetch failed: #{e.message}"
  rescue CfWod::WorkoutParser::UnparseableError => e
    abort "Parse failed: #{e.message}"
  end
end
