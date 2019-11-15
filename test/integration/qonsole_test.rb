# frozen_string_literal: true

require 'test_helper'

class QonsoleTest < ActionDispatch::IntegrationTest
  test 'Qonsole page exists' do
    get '/qonsole'
    assert_select 'h2', 'Example queries'
  end
end
