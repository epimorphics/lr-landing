# frozen_string_literal: true

require 'test_helper'

class QonsoleTest < ActionDispatch::IntegrationTest
  test 'Qonsole page renders the web component configured from config/qonsole.json' do
    get '/qonsole'

    assert_response :success
    assert_select 'h1', 'SPARQL Query Editor'
    assert_select 'script[type=module][src*="qonsole"]'
    assert_select 'epi-qonsole' do |(element)|
      config = QonsoleController.qonsole_config
      assert_equal config['endpoints'], JSON.parse(element['endpoints'])
      assert_equal config['prefixes'], JSON.parse(element['prefixes'])
      assert_equal config['queries'].pluck('name'), JSON.parse(element['queries']).pluck('name')
    end
  end

  # As deployed: only development sets config.x.qonsole_endpoint
  test 'without a configured endpoint, queries go to the endpoint in config/qonsole.json' do
    get '/qonsole'

    assert_select 'epi-qonsole' do |(element)|
      assert_equal({ 'default' => '/landregistry/query' }, JSON.parse(element['endpoints']))
    end
  end

  test 'the old query URL redirects to the console, keeping the query' do
    get '/qonsole/query?q=SELECT%20*'

    assert_redirected_to '/qonsole?q=SELECT%20*'
  end
end
