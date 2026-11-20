require 'test_helper'

class FetchStimulusTextJobTest < ActiveJob::TestCase
  setup do
    @program = Program.create!(name: 'Crossfit.com')
    @date = Date.new(2025, 6, 18)
    stub_cf_wod_redirect('2025/06/18', '250618')
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/250618})
      .to_return(status: 200, body: cf_wod_fixture('modern_normal.html'))
    @schedule = @program.schedules.create!(workout: workouts(:murph), posted_at: posted_at(@date))
  end

  test 'attaches the stimulus text to the scheduled workout without parsing or importing' do
    assert_no_difference(%w[Workout.count Schedule.count]) do
      stub_llm_parser(->(*, **) { flunk 'the workout must not be parsed' }) { FetchStimulusTextJob.perform_now(@schedule.id) }
    end

    notes = workouts(:murph).reload.intended_stimulus_notes
    assert_includes notes, 'four sprint-style efforts'
    assert_not_includes notes, 'Stimulus and Strategy'
    assert_not_requested :post, 'https://api.anthropic.com/v1/messages'
  end

  test 'never overwrites existing notes' do
    workouts(:murph).update!(intended_stimulus_notes: 'Earlier stimulus.')

    FetchStimulusTextJob.perform_now(@schedule.id)

    assert_equal 'Earlier stimulus.', workouts(:murph).reload.intended_stimulus_notes
    assert_not_requested :get, %r{\Ahttps://www\.crossfit\.com/}
  end

  test 'a schedule that no longer exists is ignored' do
    assert_nothing_raised { FetchStimulusTextJob.perform_now(0) }
  end

  private

  def posted_at(date)
    ActiveSupport::TimeZone['America/Los_Angeles'].local(date.year, date.month, date.day, 18)
  end
end
