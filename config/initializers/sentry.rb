# frozen_string_literal: true

require 'version'

Rails.application.reloader.to_prepare do # rubocop:disable Metrics/BlockLength
  if ENV['SENTRY_API_KEY']
    Sentry.init do |config|
      # https://docs.sentry.io/platforms/ruby/configuration/options/#breadcrumbs-logger
      config.breadcrumbs_logger = %i[sentry_logger monotonic_active_support_logger http_logger]
      # * The DSN tells the SDK where to send events.
      config.dsn = ENV['SENTRY_API_KEY']
      # ! Only report errors in these environments:
      config.enabled_environments = %w[production prod preprod dev]
      # ! Ignore exceptions that are not useful to us
      config.excluded_exceptions += [
        'ActionController::BadRequest',
        'ActionController::RoutingError',
        'ActiveRecord::RecordNotFound'
      ]
      # * Set the environment name from the SENTRY_ENVIRONMENT configuration value
      config.environment = ENV.fetch('SENTRY_ENVIRONMENT', Rails.env)
      # ^ Default to only reporting info, warnings and errors to Sentry
      config.logger.level = Rails.application.config.log_level || :info
      # * Set the release version to the current version
      config.release = Version::VERSION
      # * Set traces_sample_rate to 1.0 to capture 100% of transactions for tracing.
      config.traces_sample_rate = Rails.env.development? ? 1.0 : 0.1
      # ! Sentry recommends adjusting this value in production hence the ternary operator.
      # * Set profiles_sample_rate to profile 100% of sampled transactions.
      config.profiles_sample_rate = Rails.env.production? ? 1.0 : 0.1
      # ! Sentry recommends adjusting this value in production hence the ternary operator.
    end

    # * Set additional tags for the Sentry event to allow for better filtering in the Sentry UI
    # ? These tags are set in either a local .env file or the instance configuration
    sentry_tags = {
      'band' => ENV.fetch('SENTRY_BAND', nil),
      'enabled' => ENV.fetch('SENTRY_ENABLED', nil),
      'hostname' => ENV.fetch('SENTRY_HOSTNAME', nil)
    }
    # * Set the tags in the Sentry event
    sentry_tags.each do |key, value|
      next if value.blank? # ! Skip if the value is nil or empty

      Sentry.set_tags(key.to_s => value)
    end
  end
end
