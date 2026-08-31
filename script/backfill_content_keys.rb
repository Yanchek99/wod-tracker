# One-off: recompute every workout's content_key. WorkoutFingerprint#assign_content_key only runs
# on save, and RefreshesWorkoutContentKey only fires on child-record writes, so any workout
# untouched since a content_fingerprint formula change (load canonicalization, segment
# unification, ...) still stores a key computed under the old formula. A stale key silently
# defeats Workout#absorb_duplicate!, which looks a new workout's fresh fingerprint up against the
# stored column.
#
# A workout whose refreshed content is already owned by another row gets a nil key (the existing
# "unresolved duplicate" state, see assignable_content_key) rather than tripping the unique index;
# those are logged for review.
#
# Run once: bin/rails runner script/backfill_content_keys.rb
class ContentKeyBackfill
  def initialize(output: $stdout)
    @output = output
  end

  def call
    changed = 0
    Workout.find_each do |workout|
      before = workout.content_key
      workout.refresh_content_key!
      next if workout.content_key == before

      changed += 1
      log("##{workout.id} #{workout.name.inspect}: #{before.inspect} -> #{workout.content_key.inspect}")
    end
    log("Refreshed #{changed} of #{Workout.count} workouts")
  end

  private

  attr_reader :output

  def log(message)
    output.puts(message)
  end
end

ContentKeyBackfill.new.call if __FILE__ == $PROGRAM_NAME
