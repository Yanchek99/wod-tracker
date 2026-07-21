module ImplicitWorkoutPart
  extend ActiveSupport::Concern

  # A persisted segment with no name, rest time, or notes of its own is an implicit wrapper --
  # either the sole top-level run of exercises backfilled by
  # BackfillSegmentsForTopLevelExercises (see db/migrate/20260713120000_...), which always built
  # its wrapper's own rounds/time_seconds/interval_scheme to match the workout-level scheme it was
  # replacing, or a plain unnamed "flat sequence" segment added through the current form. Workout
  # no longer carries a scheme of its own to compare against (see
  # db/migrate/20260713150000_drop_workout_scheme_and_exercise_workout_id.rb), so this no longer
  # needs to check the segment's scheme against anything.
  def implicit_workout_part?
    persisted? && blank_wrapper?
  end

  private

  def blank_wrapper?
    name.blank? && rest_seconds.blank? && notes.blank?
  end
end
