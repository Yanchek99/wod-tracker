require 'test_helper'

class NavigationHelperTest < ActionView::TestCase
  setup { Current.user = users(:mathew) }
  teardown { Current.reset }

  test 'nav_items lists the five destinations in order when the user has schedules' do
    assert_predicate Current.user.schedules, :any?
    assert_equal %i[schedules workouts programs personal_records logs], nav_items.map(&:key)
  end

  test 'nav_items groups personal records and logs under progress' do
    grouped = nav_items.select { |item| item.group == :progress }.map(&:key)

    assert_equal %i[personal_records logs], grouped
  end

  test 'nav_items omits schedules when the user has none' do
    Schedule.delete_all

    assert_equal %i[workouts programs personal_records logs], nav_items.map(&:key)
  end

  test 'personal records item keeps the weightlifting family target and PRs short label' do
    item = nav_items.find { |nav_item| nav_item.key == :personal_records }

    assert_equal family_user_personal_records_path(Current.user, family: 'weightlifting'), item.path
    assert_equal 'PRs', item.short_label
    assert_equal 'Personal records', item.label
  end

  test 'nav_active? matches only the current controller' do
    define_singleton_method(:controller_name) { 'workouts' }

    active = nav_items.select { |item| nav_active?(item) }.map(&:key)

    assert_equal [:workouts], active
  end
end
