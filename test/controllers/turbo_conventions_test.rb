require 'test_helper'

class TurboConventionsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:mathew)
  end

  test 'application layout uses turbo and bootstrap attributes' do
    get workouts_url

    assert_response :success
    assert_select 'link[data-turbo-track="reload"]'
    assert_select 'script[data-turbo-track="reload"]'
    assert_select 'button.navbar-toggler[data-bs-toggle="collapse"][data-bs-target="#navbarSupportedContent"]'
    assert_select 'a[href=?][data-turbo-method="delete"]', destroy_user_session_path
  end

  test 'account removal uses turbo delete with confirmation' do
    get edit_user_registration_url

    assert_response :success
    assert_select 'a[href=?][data-turbo-method="delete"][data-turbo-confirm="Are you sure?"]',
                  user_registration_path
  end

  test 'program actions use turbo methods' do
    get program_url(programs(:local_gym))

    assert_response :success
    assert_select 'a[href=?][data-turbo-method="post"]', subscribe_program_path(programs(:local_gym))

    subscriptions(:one).update!(role: :athlete)
    get program_url(programs(:crossfit))

    assert_response :success
    assert_select 'a[href=?][data-turbo-method="delete"]', unsubscribe_program_path(programs(:crossfit))

    subscriptions(:one).update!(role: :owner)
    get program_url(programs(:crossfit))

    assert_response :success
    assert_select 'a[href=?][data-turbo-method="delete"]', program_path(programs(:crossfit))
  end

  test 'program actions allow legacy roleless subscribers to unsubscribe' do
    # rubocop:disable Rails/SkipsModelValidations
    subscriptions(:one).update_column(:role, nil)
    # rubocop:enable Rails/SkipsModelValidations

    get program_url(programs(:crossfit))

    assert_response :success
    assert_select 'a[href=?][data-turbo-method="delete"]', unsubscribe_program_path(programs(:crossfit))
  end

  test 'program unsubscribe redirects to reload action buttons' do
    delete unsubscribe_program_url(programs(:crossfit))

    assert_response :see_other
    assert_redirected_to program_url(programs(:crossfit))

    follow_redirect!

    assert_select 'a[href=?][data-turbo-method="delete"]', unsubscribe_program_path(programs(:crossfit)), false
    assert_select 'a[href=?][data-turbo-method="post"]', subscribe_program_path(programs(:crossfit))
  end

  test 'log deletion uses turbo method' do
    get log_url(logs(:matt_murph))

    assert_response :success
    assert_select 'a[href=?][data-turbo-method="delete"]', log_path(logs(:matt_murph))
  end

  test 'amrap log form does not wire score input to movement recording auto calculation' do
    get new_workout_log_url(workouts(:amrap_couplet))

    assert_response :success
    assert_select 'form[data-controller="log-form"]', false
    assert_select 'input[data-auto-calc-reps]', false
  end

  test 'workout form uses nested form controller' do
    get new_manual_workouts_url

    assert_response :success
    assert_select '.workout-builder-toolbar[role="toolbar"]' do
      assert_select '.workout-builder-toolbar__actions'
      assert_select 'button[type="submit"]', text: 'Save Workout'
      assert_select 'a[href=?]', workouts_path, text: 'Cancel Workout'
      assert_select 'a[data-action="click->nested-form#add"][data-nested-form-template="segment"]', text: 'Add Segment'
      assert_select '.fa-floppy-disk'
      assert_select '.fa-xmark'
      assert_select '.fa-layer-group'
      assert_select 'a[data-turbo-method="delete"]', false
    end
    assert_select '.form-actions', false
    assert_select '[data-controller~="nested-form"][data-nested-form-position-segments-value="true"]'
    assert_select 'template[data-nested-form-target="template"]'
    assert_select 'a[data-action="click->nested-form#add"]', text: 'Add Exercise'
  end

  test 'workout edit form cancels to the workout show page' do
    get edit_workout_url(workouts(:fran))

    assert_response :success
    assert_select '.workout-builder-toolbar a[href=?]', workout_path(workouts(:fran)), text: 'Cancel Workout'
    assert_select '.workout-builder-toolbar a[href=?][data-turbo-method="delete"][data-turbo-confirm="Are you sure?"]',
                  workout_path(workouts(:fran)),
                  text: 'Delete Workout'
    assert_select '.workout-builder-toolbar .fa-trash-can'
  end

  test 'movement and metric selects use stimulus controllers' do
    get edit_workout_url(workouts(:fran))

    assert_response :success
    # Exercise prescriptions are direct columns now; only the movement select remains here.
    assert_select 'select.movement[data-controller="movement-select"]'

    get new_workout_log_url(workouts(:murph))

    assert_response :success
    # Movement recordings are direct columns now; only the movement select remains.
    assert_select 'select.movement[data-controller="movement-select"]'
  end
end
