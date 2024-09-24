# frozen_string_literal: true

# :nodoc:
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :change_default_caching_policy

  # Set the user's preferred locale. An explicit locale set via the URL param
  # `lang` is preeminent, otherwise we look to the user's preferred language
  # specified via browser headers
  def set_locale
    user_locale = params['lang']
    user_locale ||= http_accept_language.compatible_language_from(I18n.available_locales)

    I18n.locale = user_locale if Rails.application.config.welsh_language_enabled
  end

  # * Set cache control headers for HMLR apps to be public and cacheable
  # * Landing Page uses a time limit of 5 minutes (300 seconds)
  # Sets the default `Cache-Control` header for all requests,
  # unless overridden in the action
  def change_default_caching_policy
    expires_in 5.minutes, public: true, must_revalidate: true if Rails.env.production?
  end

  # Notify subscriber(s) of an internal error event with the payload of the
  # exception once done
  # @param [Exception] exp the exception that caused the error
  # @return [ActiveSupport::Notifications::Event] provides an object-oriented
  # interface to the event
  #!IMPORTANT: This method is not used in the codebase and is only here for reference
  def instrument_internal_error(exception)
    ActiveSupport::Notifications.instrument('internal_error.application', exception: exception)
  end
end
