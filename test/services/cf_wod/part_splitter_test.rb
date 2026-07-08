require 'test_helper'

module CfWod
  class PartSplitterTest < ActiveSupport::TestCase
    test 'returns a single flat part for a body with no segment markers' do
      body = "5 power snatches\n10 overhead walking lunges\n1 rope climb, 15-ft. rope\n\n" \
             "Men: 95 lb.\nWomen: 65 lb.\n\nScroll for scaling options.\nPost rounds completed to comments."

      result = PartSplitter.call(body)

      assert_equal 1, result[:parts].length
      part = result[:parts].first
      assert_not part[:segment]
      assert_equal ['5 power snatches', '10 overhead walking lunges', '1 rope climb, 15-ft. rope'], part[:lines]
      assert_equal "Men: 95 lb.\nWomen: 65 lb.", result[:prescription_text]
      assert_equal "Scroll for scaling options.\nPost rounds completed to comments.", result[:notes]
    end

    test 'returns a nil notes when nothing matches the irrelevant-line patterns' do
      result = PartSplitter.call("5 burpees\n10 air squats")
      assert_nil result[:notes]
    end

    test 'splits sequential parts, closing the segment on a bare "Then," continuation' do
      body = "Run 800 meters\nThen, 10 rounds of the couplet:\n10 handstand push-ups\n10 single-leg squats\n" \
             'Then, run 800 meters'

      parts = PartSplitter.call(body)[:parts]

      assert_equal 3, parts.length
      assert_equal({ segment: false, name: nil, time_seconds: nil, rounds: nil, lines: ['Run 800 meters'] }, parts[0])
      assert parts[1][:segment]
      assert_equal 10, parts[1][:rounds]
      assert_equal ['10 handstand push-ups', '10 single-leg squats'], parts[1][:lines]
      assert_equal({ segment: false, name: nil, time_seconds: nil, rounds: nil, lines: ['run 800 meters'] }, parts[2])
    end

    test 'splits time-windowed parts' do
      body = "0:00-5:00:\n200-meter run\nMax freestanding shoulder taps\n\n5:00-10:00:\n200-meter run\n" \
             'Max skin-the-cats'

      parts = PartSplitter.call(body)[:parts]

      assert_equal 2, parts.length
      assert parts[0][:segment]
      assert_equal '0:00-5:00', parts[0][:name]
      assert_equal 300, parts[0][:time_seconds]
      assert_equal ['200-meter run', 'Max freestanding shoulder taps'], parts[0][:lines]
      assert_equal '5:00-10:00', parts[1][:name]
    end

    test 'extracts a prescription block that binds across the whole workout, not just the last part' do
      body = "0:00-5:00:\n200-meter run\nMax freestanding shoulder taps\n\n15:00-20:00:\n200-meter run\n" \
             "Max deficit push-ups\n\nFemale 2-inch deficit\nMale 4-inch deficit"

      result = PartSplitter.call(body)

      assert_equal "Female 2-inch deficit\nMale 4-inch deficit", result[:prescription_text]
      assert_equal ['200-meter run', 'Max deficit push-ups'], result[:parts].last[:lines]
    end

    test 'returns a nil prescription_text when there is no Rx block' do
      result = PartSplitter.call("5 burpees\n10 air squats")
      assert_nil result[:prescription_text]
    end

    test 'drops a "Partition the ... reps any way." boilerplate instruction as irrelevant' do
      body = "800-meter run\n80 pull-ups\n80 deadlifts\n800-meter run\n\n" \
             "Partition the pull-up and deadlift reps any way.\n\n" \
             "♀ 95-lb barbell\n♂ 135-lb barbell"

      result = PartSplitter.call(body)

      assert_equal 1, result[:parts].length
      assert_equal ['800-meter run', '80 pull-ups', '80 deadlifts', '800-meter run'], result[:parts].first[:lines]
      assert_equal "♀ 95-lb barbell\n♂ 135-lb barbell", result[:prescription_text]
      assert_equal 'Partition the pull-up and deadlift reps any way.', result[:notes]
    end

    test 'drops the generic "Partition the reps any way you like." template phrasing too' do
      body = "50 pull-ups\n50 deadlifts\n\nPartition the reps any way you like.\n\nMen: 135 lb.\nWomen: 95 lb."

      result = PartSplitter.call(body)

      assert_equal ['50 pull-ups', '50 deadlifts'], result[:parts].first[:lines]
    end
  end
end
