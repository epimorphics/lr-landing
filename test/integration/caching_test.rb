# frozen_string_literal: true

require 'test_helper'

# Pages are sent with `Cache-Control: public`, so a shared cache may store them
# and replay them to everyone. A response that sets a cookie must not be one of
# them, so pages set none: the app has nothing to keep in a session
class CachingTest < ActionDispatch::IntegrationTest
  # The test environment turns forgery protection off. Turn it on, as in
  # production, since it is what would put a CSRF token in the session
  setup do
    @allow_forgery_protection = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
  end

  teardown do
    ActionController::Base.allow_forgery_protection = @allow_forgery_protection
  end

  %w[/ /landing/hpi /doc/hpi /doc/ppd /accessibility /privacy /qonsole].each do |path|
    test "#{path} sets no cookie" do
      get path

      assert_response :ok
      assert_nil response.headers['set-cookie']
      assert_select 'meta[name="csrf-token"]', count: 0
    end
  end
end
