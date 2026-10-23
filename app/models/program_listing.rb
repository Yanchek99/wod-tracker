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

  # Programs the user follows first, then the rest; each group alphabetical.
  def rows
    programs = Program.order(:name).to_a
    rows = programs.map { |program| row_for(program) }
    rows.partition(&:role).flatten
  end

  private

  def row_for(program)
    Row.new(program: program, followers: follower_counts.fetch(program.id, 0), workouts: workout_counts.fetch(program.id, 0),
            latest_posted_at: latest_posts[program.id], role: roles[program.id])
  end

  def follower_counts
    @follower_counts ||= Subscription.group(:program_id).count
  end

  def workout_counts
    @workout_counts ||= Schedule.group(:program_id).count
  end

  def latest_posts
    @latest_posts ||= Schedule.where(posted_at: ..Time.current).group(:program_id).maximum(:posted_at)
  end

  def roles
    @roles ||= Subscription.where(user_id: @user.id).pluck(:program_id, :role).to_h
  end
end
