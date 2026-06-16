class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  enum :role, { admin: 0, user: 1 }
  attribute :sex, :integer
  enum :sex, { female: 0, male: 1 }

  has_many :logs, dependent: :destroy
  has_many :movement_logs, through: :logs
  has_many :workouts, -> { distinct }, through: :logs
  has_many :movements, -> { distinct }, through: :movement_logs
  has_many :subscriptions, dependent: :destroy
  has_many :programs, through: :subscriptions do
    def manageable
      where(subscriptions: { role: [:owner, :coach] })
    end
  end
  has_many :schedules, through: :programs
  has_many :scheduled_workouts, through: :schedules, source: :workout, class_name: 'Workout'

  validates :email, :first_name, :last_name, :weight, :sex, presence: true

  def name
    "#{first_name} #{last_name}"
  end

  def subscribed?(program)
    programs.include?(program)
  end

  def logged_workout?(workout)
    workouts.find_by(id: workout.id).present?
  end

  def personal_records
    movement_logs
      .where('reps IS NOT NULL OR load IS NOT NULL OR distance IS NOT NULL ' \
             'OR calories IS NOT NULL OR duration_seconds IS NOT NULL')
      .order(Arel.sql('COALESCE(load, distance, calories, duration_seconds, reps)'))
      .uniq(&:movement_id)
  end
end
