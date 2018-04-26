class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :logs, dependent: :destroy
  has_many :movement_logs, through: :logs
  has_many :workouts, -> { distinct }, through: :logs
  has_many :movements, -> { distinct }, through: :movement_logs

  def logged_workout?(workout)
    workouts.find_by(id: workout.id).present?
  end

  def personal_records
    movement_logs.joins(:movements).group('movements.id').order(measurement_value: :desc)
  end
end
