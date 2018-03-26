class Log < ApplicationRecord
  enum measurement: [:reps, :rounds, :weight, :time, :calories]

  belongs_to :workout
end
