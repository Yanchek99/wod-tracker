require 'test_helper'

class StimulusScrapeJobTest < ActiveJob::TestCase
  setup do
    @program = Program.create!(name: 'Crossfit.com')
    @date = Date.new(2025, 6, 18)
    stub_cf_wod_redirect('2025/06/18', '250618')
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/250618})
      .to_return(status: 200, body: cf_wod_fixture('modern_normal.html'))
  end

  test 'an already-scheduled day only gets its stimulus prose attached' do
    schedule = @program.schedules.create!(workout: workouts(:murph), posted_at: posted_at(@date))

    assert_no_difference(%w[Workout.count Schedule.count]) do
      stub_llm_parser(->(*, **) { flunk 'the workout must not be re-parsed' }) { StimulusScrapeJob.perform_now(@date) }
    end

    assert_equal workouts(:murph), schedule.reload.workout
    assert_includes workouts(:murph).reload.intended_stimulus_notes, 'four sprint-style efforts'
    assert_not_includes workouts(:murph).intended_stimulus_notes, 'Stimulus and Strategy'
  end

  test 'never overwrites the scheduled workout notes' do
    workouts(:murph).update!(intended_stimulus_notes: 'Earlier stimulus.')
    @program.schedules.create!(workout: workouts(:murph), posted_at: posted_at(@date))

    StimulusScrapeJob.perform_now(@date)

    assert_equal 'Earlier stimulus.', workouts(:murph).reload.intended_stimulus_notes
  end

  test 'an unscheduled day is scraped normally' do
    stub_request(:post, 'https://api.anthropic.com/v1/messages').to_return(status: 500)

    stub_llm_parser(->(*, **) { Workout.new(name: 'CF-250618', score_type: :time) }) do
      StimulusScrapeJob.perform_now(@date)
    end

    assert_equal 'CF-250618', @program.schedules.sole.workout.name
  end

  private

  def posted_at(date)
    ActiveSupport::TimeZone['America/Los_Angeles'].local(date.year, date.month, date.day, 18)
  end
end
