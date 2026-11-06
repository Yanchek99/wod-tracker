require 'test_helper'

class ProgramsHelperTest < ActionView::TestCase
  test 'role_pill renders a labeled pill per role' do
    { 'owner' => 'Owner', 'coach' => 'Coach', 'athlete' => 'Athlete' }.each do |role, label|
      html = role_pill(role)

      assert_includes html, "role-pill role-pill--#{role}"
      assert_includes html, ">#{label}<"
    end
  end

  test 'role_pill is nil without a role' do
    assert_nil role_pill(nil)
  end

  test 'unfollow confirm names the program' do
    assert_includes unfollow_confirm_message(Program.new(name: 'Crossfit')), 'Unfollow Crossfit?'
  end

  test 'delete confirm spells out the workouts and followers affected' do
    message = delete_confirm_message(Program.new(name: 'Crossfit'), workouts: 96, followers: 14)

    assert_includes message, 'Delete Crossfit?'
    assert_includes message, '96 scheduled workouts'
    assert_includes message, '14 followers'
    assert_includes message, "can't be undone"
  end

  test 'delete confirm uses singular nouns for one' do
    message = delete_confirm_message(Program.new(name: 'Solo'), workouts: 1, followers: 1)

    assert_includes message, '1 scheduled workout '
    assert_includes message, '1 follower.'
  end
end
