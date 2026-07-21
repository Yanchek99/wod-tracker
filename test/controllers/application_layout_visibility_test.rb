require 'test_helper'

class ApplicationLayoutVisibilityTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'does not render admin link for regular users' do
    users(:mathew).update!(role: :user)

    sign_in users(:mathew)
    get workouts_url

    assert_response :success
    assert_select 'a[href=?]', rails_admin_path, count: 0
  end

  test 'renders admin link for admin users' do
    users(:brooke).update!(role: :admin)

    sign_in users(:brooke)
    get workouts_url

    assert_response :success
    assert_select 'a[href=?]', rails_admin_path, text: 'Admin'
  end
end
