require 'test_helper'

class ProgramsIndexTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:mathew)
    sign_in @user
  end

  test 'lists followed programs first under Following and the rest under Other programs' do
    get programs_url

    assert_response :success
    assert_select '.program-group-label', text: 'Following'
    assert_select '.program-group-label', text: 'Other programs'
    names = css_select('.program-name').map { |node| node.text.strip }

    assert_equal ['Crossfit', 'Local Gym'], names
  end

  test 'group headings are omitted when everything is in one group' do
    Subscription.where(user: @user).destroy_all
    Subscription.create!(user: @user, program: programs(:local_gym), role: :athlete)
    Subscription.create!(user: @user, program: programs(:crossfit), role: :athlete)

    get programs_url

    assert_select '.program-group-label', count: 0
  end

  test 'owner row shows an Owner pill and a Delete button with a confirm' do
    program = Program.create!(name: 'Mine')
    program.subscriptions.create!(user: @user, role: :owner)

    get programs_url

    row = row_for('Mine')

    assert_select row, '.role-pill--owner', text: 'Owner'
    assert_select row, 'form[action=?][data-turbo-confirm*="Delete Mine?"]', program_path(program)
    assert_select row, 'form[action=?]', unsubscribe_program_path(program), count: 0
  end

  test 'coach and athlete rows show a clickable Following that unfollows after a confirm' do
    coached = Program.create!(name: 'Coached')
    coached.subscriptions.create!(user: @user, role: :coach)

    get programs_url

    assert_select row_for('Coached'), '.role-pill--coach', text: 'Coach'
    assert_select row_for('Coached'), 'form[action=?][data-turbo-confirm*="Unfollow Coached?"]', unsubscribe_program_path(coached)
    assert_select row_for('Crossfit'), '.role-pill--athlete', text: 'Athlete'
    assert_select row_for('Crossfit'), 'form[action=?]', unsubscribe_program_path(programs(:crossfit))
  end

  test 'a program you do not follow shows Follow and no pill' do
    get programs_url

    assert_select row_for('Local Gym'), 'form[action=?]', subscribe_program_path(programs(:local_gym))
    assert_select row_for('Local Gym'), '.role-pill', count: 0
  end

  test 'rows show follower and workout counts and link to the program' do
    get programs_url

    assert_select row_for('Crossfit'), '.program-facts', text: /1 follower/
    assert_select row_for('Crossfit'), '.program-facts', text: /1 workout/
    assert_select row_for('Crossfit'), 'a.program-name[href=?]', program_path(programs(:crossfit))
  end

  test 'following from the list returns to the list' do
    post subscribe_program_url(programs(:local_gym)), headers: { 'HTTP_REFERER' => programs_url }

    assert_redirected_to programs_url
  end

  test 'unfollowing from the list returns to the list' do
    delete unsubscribe_program_url(programs(:crossfit)), headers: { 'HTTP_REFERER' => programs_url }

    assert_redirected_to programs_url
  end

  test 'the whole row is clickable through the name link, with the actions kept above it' do
    get programs_url

    assert_select row_for('Crossfit'), 'a.program-name.stretched-link[href=?]', program_path(programs(:crossfit))
    assert_select row_for('Crossfit'), '.program-actions'
  end

  test 'header offers New program' do
    get programs_url

    assert_select '.page-header a[href=?]', new_program_path
  end

  test 'shows an empty state without programs' do
    Program.destroy_all

    get programs_url

    assert_select '.empty-state', text: /No programs yet/
  end

  test 'query count does not grow with the number of programs' do
    get programs_url
    small = request_query_count
    8.times { |i| Program.create!(name: "More #{i}").subscriptions.create!(user: @user, role: :athlete) }

    assert_equal small, request_query_count
  end

  private

  def row_for(name)
    css_select('.program-row').find { |node| node.at_css('.program-name').text.strip == name }
  end

  def request_query_count
    ActiveRecord::Base.connection.clear_query_cache
    count = 0
    counter = ->(*, payload) { count += 1 unless payload[:cached] || payload[:name] == 'SCHEMA' }
    ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') { get programs_url }
    count
  end
end
