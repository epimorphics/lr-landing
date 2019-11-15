# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

# Removed link to rails/test_help since it's causing an error initialising
# ActiveRecord, which we don't need. So I've just transcluded the contents
# of that file
# require "rails/test_help"

require 'active_support/test_case'
require 'action_controller'
require 'action_controller/test_case'
require 'action_dispatch/testing/integration'
require 'rails/generators/test_case'

require 'active_support/testing/autorun'

class ActionController::TestCase
  def before_setup # :nodoc:
    @routes = Rails.application.routes
    super
  end
end

class ActionDispatch::IntegrationTest
  def before_setup # :nodoc:
    @routes = Rails.application.routes
    super
  end
end
