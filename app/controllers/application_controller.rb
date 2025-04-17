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
    # Get the user's locale from the URL param `lang` or the browser headers
    user_locale = params['lang']
    user_locale ||= http_accept_language.compatible_language_from(I18n.available_locales)

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


  # Handle specific types of exceptions and render the appropriate error page
  # or attempt to render a generic error page if no specific error page exists
  unless Rails.application.config.consider_all_requests_local
    rescue_from StandardError do |e|
      # Trigger the appropriate error handling method based on the exception
      case e.class
      when ActionController::RoutingError, ActionView::MissingTemplate
        :render404
      when ActionController::InvalidCrossOriginRequest
        :render403
      when ActionController::BadRequest, ActionController::ParameterMissing
        :render400
      else
        :handle_internal_error
      end
    end
  end

  # Render the appropriate error page based on the exception
  def handle_internal_error(exception)
    case exception.instance_of?
    when ArgumentError
      render_error(400)
    when UnprocessableEntity
      render_error(422)
    else
      Rails.logger.warn "No explicit error page for exception #{exception} - #{exception.class}"
      # Instrument ActiveSupport::Notifications for internal server errors only:
      sentry_code = instrument_internal_error(exception)
      render_error(500, sentry_code)
    end
  end

  def render_400(_exception = nil) # rubocop:disable Naming/VariableNumber
    render_error(400)
  end

  def render_403(_exception = nil) # rubocop:disable Naming/VariableNumber
    render_error(403)
  end

  def render_404(_exception = nil) # rubocop:disable Naming/VariableNumber
    render_error(404)
  end

  def render_500(_exception = nil) # rubocop:disable Naming/VariableNumber
    render_error(500)
  end

  def render_error(status, sentry_code = nil)
    reset_response

    status = Rack::Utils::SYMBOL_TO_STATUS_CODE[status] if status.is_a?(Symbol)

    respond_to do |format|
      format.html { render_html_error_page(status, sentry_code) }
      # Anything else returns the status as human readable plain string
      format.all { render plain: Rack::Utils::HTTP_STATUS_CODES[status].to_s, status: status }
    end
  end

  def render_html_error_page(status, sentry_code)
    render 'exceptions/error_page',
           locals: { status: status, sentry_code: sentry_code },
           layout: true,
           status: status
  end

  def render_request_error(user_selections, status_code)
    # Convert status code to integer if it is a symbol
    status_code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status_code] if status_code.is_a?(Symbol)
    respond_to do |format|
      format.html { render_html_error_page(status_code, nil) }

      format.json do
        render(json: { status: 'request error' }, status: status_code)
      end
    end
  end

  def reset_response
    self.response_body = nil
  end



  # Notify subscriber(s) of an internal error event with the payload of the
  # exception once done
  # @param [exc] exp the exception that caused the error
  # @return [ActiveSupport::Notifications::Event] provides an object-oriented
  # interface to the event
  # !IMPORTANT: This method is not used in the codebase and is only here for reference
  def instrument_internal_error(exc) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    err = {
      message: exc&.message || exc,
      status: exc&.status || Rack::Utils::SYMBOL_TO_STATUS_CODE[exc]
    }
    byebug
    err[:type] = exc.class&.name if exc&.class
    err[:cause] = exc&.cause if exc&.cause
    err[:backtrace] = exc&.backtrace if exc&.backtrace && Rails.env.development?
    # Log the exception to the Rails logger with the appropriate severity
    Rails.logger.send(err[:status] < 500 ? :warn : :error, JSON.generate(err))
    # Return unless the status code is 500 or greater to ensure subscribers are NOT notified
    return unless err[:status] >= 500

    # Instrument the internal error event to notify subscribers of the error
    ActiveSupport::Notifications.instrument('internal_error.application', exception: err)
  end
end
