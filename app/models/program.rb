class Program < ApplicationRecord
  has_many :schedules, dependent: :destroy
  has_many :workouts, through: :schedules
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions
end
