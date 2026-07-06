namespace :cf_wod do
  desc "Fetch and parse a single day's WOD from crossfit.com and print the result (does not persist)"
  task :fetch, [:date] => :environment do |_task, args|
    abort 'Usage: bin/rails "cf_wod:fetch[YYYY-MM-DD]"' if args[:date].blank?

    page = CfWod::Fetcher.call(Date.parse(args[:date]))
    pp CfWod::WorkoutParser.call(page)
  rescue CfWod::FetchError => e
    abort "Fetch failed: #{e.message}"
  end
end
