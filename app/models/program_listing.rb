# The Programs list: one row per program with its follower and workout counts, the latest past post, and
# the viewing user's role. Constant query count regardless of how many programs exist.
class ProgramListing
  Row = Data.define(:program, :followers, :workouts, :latest_posted_at, :role)

  def self.for(user)
    new(user).rows
  end

  def initialize(user)
    @user = user
  end

  # Programs the user follows first, then the rest; each group alphabetical. Subscriptions are preloaded so the
  # permission checks the views make per row don't query per program.
  def rows
    rows = Program.includes(:subscriptions).order(:name).map { |program| row_for(program) }
    rows.partition(&:role).flatten
  end

  private

  def row_for(program)
    Row.new(program: program, followers: program.subscriptions.size, workouts: workout_counts.fetch(program.id, 0),
            latest_posted_at: latest_posts[program.id], role: role_in(program))
  end

  def role_in(program)
    subscription = program.subscriptions.find { |candidate| candidate.user_id == @user.id }
    # Roleless legacy subscriptions behave as athletes until the backfill has run everywhere.
    subscription && (subscription.role || 'athlete')
  end

  def workout_counts
    @workout_counts ||= Schedule.group(:program_id).count
  end

  def latest_posts
    @latest_posts ||= Schedule.posted_through_today.group(:program_id).maximum(:posted_at)
  end
end
