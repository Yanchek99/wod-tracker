namespace :capabilities do
  desc 'Enqueue a heuristic capability recompute for every user'
  task backfill: :environment do
    count = 0
    User.find_each do |user|
      RecomputeCapabilitiesJob.perform_later(user.id)
      count += 1
    end
    puts "Enqueued capability recompute for #{count} users"
  end
end
