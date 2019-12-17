# frozen-string-literal: true

Raven.configure do |config|
  config.dsn = 'https://0296b9563a944ef4bb6e41ffdc3fe4d2@sentry.io/1859729'
  config.current_environment = ENV['DEPLOYMENT_ENVIRONMENT'] || Rails.env
  config.environments = %w[production test]
  config.release = Version::VERSION
  config.tags = { app: 'lr-dgu-landing' }
end
