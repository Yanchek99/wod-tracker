require 'test_helper'

class IconsHelperTest < ActionView::TestCase
  NAMES = %i[calendar dumbbell clipboard_list trophy history user chevron_left chevron_right plus check log_out shield settings pencil chevron_down].freeze

  test 'icon renders an aria-hidden inline svg' do
    html = icon(:calendar)

    assert_includes html, '<svg'
    assert_includes html, 'class="icon"'
    assert_includes html, 'aria-hidden="true"'
  end

  test 'icon appends extra classes' do
    assert_includes icon(:plus, class: 'me-2'), 'class="icon me-2"'
  end

  test 'icon raises for an unknown name' do
    assert_raises(ArgumentError) { icon(:nope) }
  end

  test 'every named icon renders' do
    NAMES.each { |name| assert_includes icon(name), '<svg', "#{name} did not render" }
  end
end
