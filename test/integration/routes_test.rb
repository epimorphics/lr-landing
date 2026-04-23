# frozen_string_literal: true

require 'test_helper'

# This is a set of tests to ensure that the expected routes are handled
# correctly by the application
class RoutesTest < ActionDispatch::IntegrationTest
  # This test ensures that any unmatched routes are handled gracefully by rendering the 404 page
  test 'unknown routes render the 404 page in English' do
    get '/this-route-does-not-exist', params: { lang: 'en' }

    assert_response :not_found
    assert_select '.o-heading--1', 'Page not found'
  end
end
