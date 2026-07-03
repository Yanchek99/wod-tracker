namespace :cf_wod do
  desc "Fetch a single day's WOD from crossfit.com and print it (does not persist)"
  task :fetch, [:date] => :environment do |_task, args|
    abort 'Usage: bin/rails "cf_wod:fetch[YYYY-MM-DD]"' if args[:date].blank?

    page = CfWod::Fetcher.call(Date.parse(args[:date]))
    pp page
  rescue CfWod::Fetcher::FetchError => e
    abort "Fetch failed: #{e.message}"
  end
end
