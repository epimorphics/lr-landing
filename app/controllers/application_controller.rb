# frozen_string_literal: true

# :nodoc:
class ApplicationController < ActionController::Base
  # No forgery protection: the site only answers GET requests and changes
  # nothing for anyone, so there is no request to forge. With protection on, the
  # layout's `csrf_meta_tags` put a token in the session, so every page set a
  # session cookie while telling shared caches it was public. Turn this back on
  # if the app ever accepts a form, and stop caching those pages publicly
  self.allow_forgery_protection = false
  before_action :set_locale
  before_action :change_default_caching_policy

  # Set the user's preferred locale. An explicit locale set via the URL param
  # `lang` is preeminent, otherwise we look to the user's preferred language
  # specified via browser headers, then the default locale (as when the headers
  # are missing or name no language we support). A `lang` we don't support,
  # including a blank one, is ignored rather than passed to I18n, which would
  # raise I18n::InvalidLocale: on an error page, that would break the page too
  def set_locale
    # Get the user's locale from the URL param `lang` or the browser headers
    lang = params['lang']
    user_locale = lang.presence_in(I18n.available_locales.map(&:to_s))
    user_locale ||= http_accept_language.compatible_language_from(I18n.available_locales)
    user_locale ||= I18n.default_locale

    # Now convert the user's locale to a symbol and set it as the I18n locale
    I18n.locale = user_locale.to_sym if Rails.application.config.welsh_language_enabled
  end

  # * Set cache control headers for HMLR apps to be public and cacheable
  # * Landing Page uses a time limit of 5 minutes (300 seconds)
  # Sets the default `Cache-Control` header for all requests,
  # unless overridden in the action
  def change_default_caching_policy
    expires_in 5.minutes, public: true, must_revalidate: true if Rails.env.production?
  end

  def version
    render json: { version: Version::VERSION }
  end
end
