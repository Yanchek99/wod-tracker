require 'test_helper'

class SchedulesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:mathew)
  end

  test 'index batches logged workout lookup for rendered schedules' do
    Schedule.create!(
      program: programs(:crossfit),
      workout: workouts(:murph),
      posted_at: schedules(:one).posted_at
    )

    query_counts = count_matching_queries(logs: /FROM "logs"/, exercises: /FROM "exercises"/) do
      get schedules_url
    end

    assert_response :success
    assert_equal 1, query_counts[:logs]
    assert_equal 1, query_counts[:exercises]
  end

  private

  def count_matching_queries(patterns, &)
    counts = patterns.transform_values { 0 }
    callback = lambda do |_name, _started, _finished, _unique_id, payload|
      next if payload[:cached] || payload[:name] == 'SCHEMA'

      patterns.each { |name, pattern| counts[name] += 1 if payload[:sql].match?(pattern) }
    end

    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record', &)

    counts
  end
end
