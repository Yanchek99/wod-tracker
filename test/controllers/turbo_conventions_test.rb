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

  test 'log deletion uses turbo method' do
    get log_url(logs(:matt_murph))

    assert_response :success
    assert_select 'a[href=?][data-turbo-method="delete"]', log_path(logs(:matt_murph))
  end

  test 'round log score input enables rep auto calculation' do
    metrics(:murph).update!(measurement: :round)

    get new_workout_log_url(workouts(:murph))

    assert_response :success
    assert_select 'form[data-controller="log-form"]'
    assert_select 'input[data-auto-calc-reps="true"][data-action="keyup->log-form#calculateReps"]'
    assert_select '[data-controller="nested-form"] template[data-nested-form-target="template"]'
  end

  test 'workout form uses nested form controller' do
    get new_workout_url

    assert_response :success
    assert_select '[data-controller="nested-form"][data-nested-form-position-exercises-value="true"]'
    assert_select 'template[data-nested-form-target="template"]'
    assert_select 'a[data-action="nested-form#add"]'
  end

  test 'movement and metric selects use stimulus controllers' do
    get edit_workout_url(workouts(:fran))

    assert_response :success
    assert_select 'select.movement[data-controller="movement-select"]'
    assert_select 'select.metric[data-controller="metric-select"]'

    get new_workout_log_url(workouts(:murph))

    assert_response :success
    assert_select 'select.movement[data-controller="movement-select"]'
    assert_select 'select.metric[data-controller="metric-select"]'
  end
end
