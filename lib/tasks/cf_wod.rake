namespace :cf_wod do
  desc "Fetch and parse a single day's workout from crossfit.com and print it (does not persist)"
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

  desc 'Run ScrapeCfWodJob for a single date, persisting the Workout/Schedule or logging a WorkoutImport failure'
  task :scrape, [:date] => :environment do |_task, args|
    abort 'Usage: bin/rails "cf_wod:scrape[YYYY-MM-DD]"' if args[:date].blank?

    date = Date.parse(args[:date])
    ScrapeCfWodJob.perform_now(date)

    workout_import = WorkoutImport.find_by(workout_date: date)
    abort "Failed: #{workout_import.error_message}" if workout_import
    puts "Scraped #{date} successfully"
  end

  desc 'Enqueue ScrapeCfWodJob for every date in a range, staggered to avoid hammering crossfit.com'
  task :backfill, %i[start_date end_date] => :environment do |_task, args|
    abort 'Usage: bin/rails "cf_wod:backfill[YYYY-MM-DD,YYYY-MM-DD]"' if args[:start_date].blank? || args[:end_date].blank?

    start_date = Date.parse(args[:start_date])
    end_date = Date.parse(args[:end_date])
    BackfillCrossfitWodsJob.perform_now(start_date, end_date)
    puts "Enqueued #{(start_date..end_date).count} days (#{start_date}..#{end_date}) for backfill"
  rescue ArgumentError => e
    abort "Backfill failed: #{e.message}"
  end
end
