require 'test_helper'

class ProgramsCreateTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:mathew)
    sign_in @user
  end

  test 'new renders a name form with Create and a Cancel back to the list' do
    get new_program_url

    assert_response :success
    assert_select '.program-title', text: 'New program'
    assert_select '.form-card form[action=?]', programs_path
    assert_select '.form-card input[name="program[name]"]'
    assert_select '.form-card input[type=submit][value="Create program"]'
    assert_select '.form-card a[href=?]', programs_path, text: 'Cancel'
  end

  test 'creating a program makes the user its owner and shows the program' do
    assert_difference -> { Program.count }, 1 do
      post programs_url, params: { program: { name: 'Brand New' } }
    end

    program = Program.find_by!(name: 'Brand New')

    assert_redirected_to program_url(program)
    assert_equal 'owner', program.subscriptions.find_by(user: @user).role
  end

  test 'a blank name re-renders the form with an error and a 422' do
    assert_no_difference -> { Program.count } do
      post programs_url, params: { program: { name: '' } }
    end

    assert_response :unprocessable_content
    assert_select '.form-card', text: /can.t be blank/
  end

  test 'a duplicate name re-renders the form with an error and a 422' do
    post programs_url, params: { program: { name: programs(:crossfit).name } }

    assert_response :unprocessable_content
    assert_select '.form-card', text: /has already been taken/
  end
end
