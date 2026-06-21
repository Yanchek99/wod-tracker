module RefreshesWorkoutContentKey
  extend ActiveSupport::Concern

  included do
    after_commit :refresh_workout_content_key
  end

  private

  # Exercises and segments are part of the workout's content fingerprint, so changing
  # one directly must refresh the parent key rather than relying on the workout being
  # saved. Skipped when the workout is gone (e.g. a dependent destroy cascade).
  def refresh_workout_content_key
    return unless workout&.persisted?

    workout.refresh_content_key!
  end
end
