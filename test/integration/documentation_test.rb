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

  test 'older PPD doc link redirects with permanent 301 status' do
    get '/doc/ppd'
    assert_equal(301, response.status)
  end

  test 'old PPD doc link redirects with permanent 301 status' do
    get '/app/root/doc/ppd'
    assert_equal(301, response.status)
  end

  test 'ppd_doc_path variable links correctly' do
    get ppd_doc_path
    assert_response :success
  end

  test 'ppd doc loads correctly' do
    get ppd_doc_path
    assert_select 'h1', 'Price Paid Linked Data'
    assert_select 'h2', 'What does the Price Paid Dataset consist of?'
  end
end
