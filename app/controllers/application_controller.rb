# frozen_string_literal: true

# :nodoc:
class ApplicationController < ActionController::Base
  include Log

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception, prepend: true
  # before_action :log_resource_usage
  before_action :set_locale
  before_action :change_default_caching_policy
  around_action :log_response

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

  # Log the response time for each request
  # This method is called around each action in the controller
  # It measures the time taken to process the request and logs it
  # The time is logged in milliseconds
  # @return [void]
  def log_response
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond)
    yield
    # Calculate elapsed time and convert to milliseconds
    duration = (Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond) - start) / 1000
    Log.info(
      'Processing request',
      {
        duration:,
        method: request.method,
        params:,
        path: request.path,
        status: response.status
      }
    )
  end

  def version
    render json: { version: Version::VERSION }
  end

  private

  # Get the current process resource usage using the `ps` command
  # -o format ~ User-defined format.  format is a single argument in the
  #             form of a blank-separated or comma-separated list, which
  #             offers a way to specify individual output columns.
  # psr: processor number last used
  # etime: elapsed time since the process started
  # pcpu: percentage of CPU used by the process
  # pmem: percentage of memory used by the process
  # rss: resident set size (physical memory used) in kilobytes
  # vsz: virtual memory size in kilobytes
  # -p pid    ~ Select by process ID
  # Source: https://discuss.rubyonrails.org/t/how-to-reduce-memory-footprint-of-a-rails-app/39388/6
  # Reference: https://man7.org/linux/man-pages/man1/ps.1.html
  def log_resource_usage
    return unless Rails.env.development? || Rails.logger.debug?

    psr, etime, pcpu, pmem, rss, vsz = `ps -o psr,etime,pcpu,pmem,rss,vsz -p #{Process.pid}`.split('\n')&.[](1)&.split(/\s+/) # rubocop:disable Layout/LineLength
    resources = { psr:, etime:, pcpu:, pmem:, rss:, vsz: }
    Rails.logger.info(
      "***DEBUG: resource_usage:
          rails_env=#{Rails.env}
          pid=#{Process.pid}
          #{resources.compact!.map { |k, v| "#{k}=#{v}" }.join(' ')}
          req_method=#{request.method}
          req_uri=#{request.url}
      "
    )
  end
end
