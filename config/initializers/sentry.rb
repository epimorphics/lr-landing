# frozen-string-literal: true

Sentry.init do |config|
  config.dsn = 'https://0296b9563a944ef4bb6e41ffdc3fe4d2@sentry.io/1859729'
  config.environment = ENV['DEPLOYMENT_ENVIRONMENT'] || Rails.env
  config.enabled_environments = %w[production test]
  config.release = Version::VERSION
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
end
