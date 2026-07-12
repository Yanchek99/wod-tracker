module CfWorkout
  WorkoutPage = Data.define(
    :date, :slug, :title, :body_html, :body_text, :description, :scaling, :rest_day, :previous_slug, :next_slug
  ) do
    def rest_day?
      rest_day
    end
  end
end
