class PersonalRecordsController < ApplicationController
  before_action :set_user

  def index
    redirect_to family_user_personal_records_path(@user, family: 'weightlifting')
  end

  def family
    @family = params.expect(:family)
    case @family
    when 'weightlifting'
      @movement_rep_maxes = weightlifting_rep_maxes
      render :weightlifting
    when 'monostructural'
      @movement_distances, @other_records = monostructural_records
      render :monostructural
    else
      @movement_logs = family_movement_logs
      render :family
    end
  end

  def repeated_workouts
    @logs = @user.workout_records.sort_by { |log| log.workout.name }
  end

  private

  def weightlifting_rep_maxes
    @user.personal_records
         .select { |record| weightlifting_rep_max?(record) }
         .group_by(&:movement)
         .sort_by { |movement, _records| movement.name }
         .map { |movement, records| [movement, records.sort_by { |record| record.verified_unbroken_reps || Float::INFINITY }] }
  end

  def weightlifting_rep_max?(record)
    record.movement.family_weightlifting? && record.load.present? && !unverified_reps_claim?(record)
  end

  def family_movement_logs
    @user.personal_records
         .select { |record| record.movement.public_send("family_#{@family}?") && !unverified_reps_claim?(record) }
         .sort_by { |m| [m.movement.name, m.reps.to_i, m.distance.to_i, m.duration_seconds.to_i] }
  end

  # A record whose reps are blank (e.g. a load-only PR, no rep count tracked at all) or <= 1 makes
  # no unverified claim. A record with reps > 1 is only trustworthy once its set_breakdown backs up
  # a genuine unbroken effort (see MovementLog#verified_unbroken_reps) -- otherwise it'd render a
  # fabricated claim, like Diane's aggregated "45RM" Deadlift or Murph's raw "100" pull-ups. Shared
  # by both the Weightlifting rep-max grouping and the Gymnastics flat list, since a gymnastics
  # rep count carries the same implicit "your real capability at N reps" claim (e.g. "max unbroken
  # pull-ups") as a weightlifting rep-max does.
  def unverified_reps_claim?(record)
    record.reps.present? && record.reps > 1 && record.verified_unbroken_reps.blank?
  end

  # Only a movement whose records are uniformly distance+time (no load) gets the grouped/expand
  # treatment -- other shapes (calorie-based, reps-in-a-time-cap) stay in the flat list below,
  # rather than forcing genuinely different kinds of record into one row format.
  def monostructural_records
    records = @user.personal_records.select { |record| record.movement.family_monostructural? }
    distance_time_records, other_records = records.partition { |record| distance_time_record?(record) }
    [grouped_distance_records(distance_time_records), sorted_other_records(other_records)]
  end

  def distance_time_record?(record)
    record.load.blank? && record.distance.present? && record.duration_seconds.present?
  end

  def grouped_distance_records(records)
    records.group_by(&:movement)
           .sort_by { |movement, _records| movement.name }
           .map { |movement, movement_records| [movement, movement_records.sort_by(&:distance), most_recent(movement_records)] }
  end

  def most_recent(records)
    records.max_by { |record| record.log.created_at }
  end

  def sorted_other_records(records)
    records.sort_by { |m| [m.movement.name, m.reps.to_i, m.distance.to_i, m.duration_seconds.to_i] }
  end

  def set_user
    @user = User.find(params.expect(:user_id))
  end
end
