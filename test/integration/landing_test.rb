# frozen_string_literal: true

require 'test_helper'

class LandingTest < ActionDispatch::IntegrationTest
  test 'landing page main content' do
    get('/', params: { lang: 'en' })
    assert_select 'h1', 'Open Data'
    assert_select 'main p', /HM Land Registry/
  end

  test 'landing page in Welsh' do
    get('/', params: { lang: 'cy' })

    assert_select 'h1', 'Data Agored'
    assert_select 'main p', /Gofrestrfa Tir/
  end

  test 'version number is visible' do
    get '/'
    assert_select '.o-version', /#{Version::VERSION}/
  end
end
