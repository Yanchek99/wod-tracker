class ExpandIntendedStimulus < ActiveRecord::Migration[8.1]
  WORKOUT_COLUMNS = %i[
    stimulus_goal
    stimulus_round_seconds_low stimulus_round_seconds_high
    stimulus_percent_1rm_low stimulus_percent_1rm_high
    stimulus_working_sets_low stimulus_working_sets_high
    stimulus_rest_seconds_low stimulus_rest_seconds_high
    stimulus_interval_work_seconds stimulus_interval_rest_seconds_min
  ].freeze

  EXERCISE_COLUMNS = %i[stimulus_rest_max_seconds stimulus_effort].freeze

  def change
    change_table :workouts, bulk: true do |t|
      WORKOUT_COLUMNS.each { |column| t.integer column }
    end

    change_table :exercises, bulk: true do |t|
      EXERCISE_COLUMNS.each { |column| t.integer column }
    end

    change_table :stimulus_predictions, bulk: true do |t|
      (WORKOUT_COLUMNS + EXERCISE_COLUMNS).each { |column| t.integer column }
    end
  end
end
