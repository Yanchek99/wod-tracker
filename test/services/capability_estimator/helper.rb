require 'test_helper'

# Shared builders for the CapabilityEstimator rule tests. Every test gets a fresh user so the
# fixture logs and capabilities never leak in.
module CapabilityEstimatorHelper
  def setup_estimator_user
    @user = User.create!(email: "est-#{SecureRandom.hex(4)}@wod-tracker.com", password: 'password123',
                         first_name: 'Est', last_name: 'Imator', weight: 150, sex: :female)
  end

  # Creates a log for @user on `workout` with one movement log per attrs hash.
  def create_log(workout, *movement_log_attrs, score_type: :time, created_at: Time.current)
    log = workout.logs.build(user: @user, score_type:, created_at:)
    movement_log_attrs.each { |attrs| log.movement_logs.build(attrs) }
    log.save!(validate: false)
    log
  end

  def samples
    CapabilityEstimator.samples_for(@user)
  end
end
