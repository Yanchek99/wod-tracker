class NoopJob < ApplicationJob
  queue_as :default

  # Intentionally does nothing; used to verify the SolidQueue pipeline.
  def perform
  end
end
