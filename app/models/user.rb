class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :logs, dependent: :destroy
  has_many :movement_logs, through: :logs
  has_many :workouts, -> { distinct }, through: :logs
  has_many :movements, -> { distinct }, through: :movement_logs
  has_many :subscriptions, dependent: :destroy
  has_many :programs, through: :subscriptions

  def subscribed?(program)
    programs.include?(program)
  end

  def logged_workout?(workout)
    workouts.find_by(id: workout.id).present?
  end

  def personal_records
    movement_logs.joins(:metrics).order('metrics.value').uniq(&:movement_id)
  end
end
