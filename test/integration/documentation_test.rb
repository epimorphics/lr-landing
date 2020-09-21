# frozen_string_literal: true

require 'test_helper'

class DocumentationTest < ActionDispatch::IntegrationTest
  test 'UKHPI docs page' do
    get '/doc/ukhpi'
    assert_equal(302, response.status)
  end

  test 'UKHPI docs page not available in Welsh' do
    get('/doc/ukhpi', params: { lang: 'cy' })

    assert_equal(302, response.status)
  end

  test 'PPD docs page' do
    get '/doc/ppd'
    assert_select 'h1', 'Price Paid Linked Data'
  end
end
