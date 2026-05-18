# frozen_string_literal: true

require File.expand_path('boot', __dir__)

# Pick the frameworks you want:
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

require 'qonsole_rails'

module LrLanding
  # :nodoc:
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Use default paths for documentation.
    config.accessibility_document_path = '/accessibility'
    config.privacy_document_path = '/privacy'

    # feature flag for showing the Welsh language switch affordance
    config.welsh_language_enabled = true

    # Set the contact email address to Land Registry supplied address
    config.contact_email_address = 'data.services@mail.landregistry.gov.uk'

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.available_locales = %i[en cy]
    config.i18n.default_locale = :en
    config.i18n.enforce_available_locales = true

    # Quiet SASS deprecation warnings coming from dependencies
    config.sass.quiet_deps = true
    # Silence @import deprecation warnings during migration to @use/@forward
    # See: https://sass-lang.com/d/import
    config.sass.silence_deprecations = ['import']
  end
end

# Monkey-patch the bit of Rails that emits the start-up log message, so
# that it is written out in JSON format that our combined logging
# service can handle
# TODO: Remove this block after adopting `epilog_rails`
module Rails # rubocop:disable Style/OneClassPerFile
  # :nodoc:
  module Command
    # :nodoc:
    class ServerCommand
      def print_boot_information(server, url)
        msg = "Starting #{server} Rails #{Rails.version} in #{Rails.env}"
        msg += " on #{url}" if url
        info = {
          ts: DateTime.now.utc.strftime('%FT%T.%3NZ'),
          level: 'INFO',
          message: msg
        }
        say info.to_json
      end
    end
  end
end
