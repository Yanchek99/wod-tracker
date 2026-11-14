require 'test_helper'

# A scraped day that resolves to an existing workout (a reposted benchmark, or a re-scraped day)
# keeps CrossFit's Stimulus and Strategy prose when that workout has none (#1992).
class ScrapeCfWodJobStimulusTest < ActiveJob::TestCase
  setup do
    Program.create!(name: 'Crossfit.com')
    stub_cf_wod_redirect('2025/06/18', '250618')
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/250618})
      .to_return(status: 200, body: cf_wod_fixture('modern_normal.html'))
  end

  test 'saves stimulus prose onto an existing catalog workout that has none, with no AI call' do
    scrape_resolving_to(workouts(:fran))

    fran = workouts(:fran).reload
    assert_includes fran.intended_stimulus_notes, 'four sprint-style efforts'
    assert_not_includes fran.intended_stimulus_notes, 'Stimulus and Strategy'
    assert_nil fran.stimulus_source
    assert_not_requested :post, 'https://api.anthropic.com/v1/messages'
  end

  test 'never overwrites existing notes on a catalog workout' do
    workouts(:fran).update!(intended_stimulus_notes: 'Earlier CrossFit Fran stimulus.')

    scrape_resolving_to(workouts(:fran))

    assert_equal 'Earlier CrossFit Fran stimulus.', workouts(:fran).reload.intended_stimulus_notes
  end

  test 'saves prose on an authored workout and leaves its values alone' do
    workouts(:fran).update!(stimulus_source: :authored, stimulus_range_high: 300)

    scrape_resolving_to(workouts(:fran))

    fran = workouts(:fran).reload
    assert_includes fran.intended_stimulus_notes, 'four sprint-style efforts'
    assert_equal [300, 'authored'], fran.values_at(:stimulus_range_high, :stimulus_source)
    assert_not_requested :post, 'https://api.anthropic.com/v1/messages'
  end

  private

  def scrape_resolving_to(workout)
    stub_llm_parser(workout) do
      perform_enqueued_jobs { ScrapeCfWodJob.perform_later(Date.new(2025, 6, 18)) }
    end
  end
end
