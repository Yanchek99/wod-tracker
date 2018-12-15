class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  enum role: { admin: 'admin', athlete: 'athelete', coach: 'coach' }

  has_many :logs, dependent: :destroy
  has_many :movement_logs, through: :logs
  has_many :workouts, -> { distinct }, through: :logs
  has_many :movements, -> { distinct }, through: :movement_logs
  has_many :subscriptions, dependent: :destroy
  has_many :programs, through: :subscriptions
  has_many :schedules, through: :programs
  has_many :scheduled_workouts, through: :schedules, source: :workout, class_name: 'Workout'

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
