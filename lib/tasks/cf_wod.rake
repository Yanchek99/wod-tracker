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

  desc 'Run ScrapeCfWodJob for a single date, persisting the Workout/Schedule or logging a WodImport failure'
  task :scrape, [:date] => :environment do |_task, args|
    abort 'Usage: bin/rails "cf_wod:scrape[YYYY-MM-DD]"' if args[:date].blank?

    date = Date.parse(args[:date])
    ScrapeCfWodJob.perform_now(date)

    wod_import = WodImport.find_by(wod_date: date)
    abort "Failed: #{wod_import.error_message}" if wod_import
    puts "Scraped #{date} successfully"
  end
end
