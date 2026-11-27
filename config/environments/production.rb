# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Serve /public, including the compiled assets, from the app: the HMLR proxy
  # passes every request through to the container and serves no files itself
  config.public_file_server.enabled = true

  # Compress JavaScripts and CSS.
  # config.assets.js_compressor = :uglifier
  config.assets.js_compressor = :terser
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true
  # `config.sass.style` has been deprecated in favor of `config.assets.css_compressor`
  # Set SASS output style to compressed for smaller file sizes
  config.sass.style = :compressed
  # SASS source maps are disabled in production for performance
  config.sass.inline_source_maps = false

  # `config.assets.precompile` and `config.assets.version` have moved to
  # config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # When sync mode is true, all output is immediately flushed to the underlying
  # operating system and is not buffered by Ruby internally.
  $stdout.sync = true
  # epilog_rails sets the logger: JSON to stdout, with a pair of entries per request
  # Don't log the rendering of each template and layout. At DEBUG these are
  # unstructured `Rendering …` lines that epilog_rails 0.3.0 fails to suppress
  # (epimorphics/epilog-rails#9).
  config.action_view.logger = nil

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # * Set cache control headers for HMLR apps to be public and cacheable
  # * Landing Page uses a time limit of 5 minutes (300 seconds)
  # This affects everything served from /public, compiled assets included.
  # No `Expires`: these headers are fixed when the app boots, so a date would be
  # in the past five minutes after each deploy, and max-age already says it
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{5.minutes.to_i}"
  }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # The RAILS_RELATIVE_URL_ROOT env var should ONLY be used in a local environment.
  # Here, the default value is passed in as the compiled assets have no knowledge
  # of the base path and utilise the config.relative_url_root value to prefix the
  # compiled asset paths
  config.relative_url_root = ENV.fetch('RAILS_RELATIVE_URL_ROOT', '/')

  # Set the log level to the value of the LOG_LEVEL environment variable, or 'info' if not set
  config.log_level = ENV.fetch('LOG_LEVEL', 'info').to_sym
end
