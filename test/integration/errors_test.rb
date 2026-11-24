# frozen_string_literal: true

require 'test_helper'

# Error pages are reached only through `config.exceptions_app`, so these tests
# cause real errors and check what the middleware renders. They assert on the
# status as well as the body: a branded page served with the wrong status is a
# bug too.
class ErrorsTest < ActionDispatch::IntegrationTest
  # The suite runs with `show_exceptions = :none`, so that controller exceptions
  # fail tests with a backtrace. These tests need the exceptions middleware on,
  # and detailed exceptions off: `consider_all_requests_local` is true in test,
  # so otherwise Rails renders its own debug page and never reaches ErrorsController
  setup do
    env = Rails.application.env_config
    @original_env = env.slice('action_dispatch.show_exceptions', 'action_dispatch.show_detailed_exceptions')
    env['action_dispatch.show_exceptions'] = :all
    env['action_dispatch.show_detailed_exceptions'] = false
  end

  teardown do
    Rails.application.env_config.merge!(@original_env)
  end

  test 'an unmatched path renders the 404 page' do
    get '/this-route-does-not-exist'

    assert_response :not_found
    assert_includes @response.body, 'Page not found'
  end

  test 'the 404 page keeps the layout and follows the language' do
    get '/this-route-does-not-exist?lang=cy'

    assert_response :not_found
    assert_select 'html body.lr-app'
    assert_select 'a[href=?]', '/accessibility?lang=cy'
  end

  test 'error pages cannot be requested directly' do
    get '/500'

    assert_response :not_found
    assert_includes @response.body, 'Page not found'
  end

  test 'an unhandled exception renders the 500 page' do
    with_failing_landing_page do
      get '/'
    end

    assert_response :internal_server_error
    assert_includes @response.body, 'Application error'
  end

  # Until #252 relabels it, the payload is the one the old handler sent
  test 'an unhandled exception is reported as an internal error' do
    events = []
    callback = ->(*, payload) { events << payload }

    with_failing_landing_page do
      ActiveSupport::Notifications.subscribed(callback, 'internal_error.application') { get '/' }
    end

    assert_equal [{ exception: { message: 'boom', status: 500, type: 'RuntimeError' } }], events
  end

  test 'a client error is not reported as an internal error' do
    events = []
    callback = ->(*, payload) { events << payload }

    ActiveSupport::Notifications.subscribed(callback, 'internal_error.application') { get '/nope' }

    assert_empty events
  end

  test 'a malformed query string renders the 400 page' do
    # Set directly: the test helper would reject this URL before it reached the app
    get '/', env: { 'QUERY_STRING' => 'sk=%%_subscriberKey%%' }

    assert_response :bad_request
    assert_includes @response.body, 'Request not understood'
  end

  test 'a malformed form body still renders the error page' do
    post '/this-route-does-not-exist', params: 'sk=%%_subscriberKey%%',
                                       headers: { 'CONTENT_TYPE' => 'application/x-www-form-urlencoded' }

    assert_response :not_found
    assert_includes @response.body, 'Page not found'
  end

  test 'an unsupported lang still renders the error page' do
    get '/this-route-does-not-exist?lang=en%5C'

    assert_response :not_found
    assert_includes @response.body, 'Page not found'
  end

  test 'a blank or unsupported lang on a real page falls back to the default' do
    ['', 'en\\'].each do |lang|
      get '/', params: { lang: }

      assert_response :success, "lang=#{lang.inspect}"
    end
  end

  test 'non-HTML requests get a plain text body with the same status' do
    get '/this-route-does-not-exist', headers: { 'Accept' => 'text/plain' }

    assert_response :not_found
    assert_equal 'Not Found', @response.body.strip
  end

  test 'error pages are not cached as public' do
    get '/this-route-does-not-exist'

    assert_not_includes @response.headers['Cache-Control'].to_s, 'public'
  end

  private

  # LandingController has no index method (the view renders implicitly), so
  # define one that raises for the length of the block
  def with_failing_landing_page
    LandingController.define_method(:index) { raise 'boom' }
    yield
  ensure
    LandingController.remove_method(:index)
    # Defining a method clears the cached list of actions; removing one doesn't
    LandingController.clear_action_methods!
  end
end
