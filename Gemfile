# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails'

# Use Puma as the app server
gem 'puma'


# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# JavaScript asset compressor
gem 'terser' # Updating to terser for ES6+ support

# Use SCSS for stylesheets, used mainly in development and test groups
gem 'autoprefixer-rails'
gem 'dartsass-sprockets', '~> 3.2'

gem 'haml-rails'

# The Qonsole Rails gem depends on a forked version of jquery-datatables-rails
# to include a fix that has not yet been merged into the main repo. See:
# https://stackoverflow.com/a/68001592/5760177
gem 'jquery-datatables-rails', '~> 3.5.0',
    github: 'marlinpierce/jquery-datatables-rails',
    branch: 'master-3.5'

gem 'get_process_mem'
gem 'http_accept_language'
gem 'prometheus-client'
gem 'puma-metrics'

# Sentry uses stackprof for performance profiling, has to be loaded before Sentry
gem 'stackprof'
gem 'sentry-rails' # rubocop:disable Bundler/OrderedGems

group :development, :test do
  gem 'byebug'
  gem 'dotenv'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'rubocop'
  gem 'rubocop-rails'
end

group :test do
  gem 'simplecov', require: false
end


group :development do
  gem 'derailed_benchmarks'
  gem 'ruby-lsp'
  gem 'solargraph'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
  gem 'haml-lint', require: false

  # NOTE: While running the rails app locally for testing you can set gems to your local path
  # ! These "local" paths do not work with a docker image - use the repo instead
  # gem 'json_rails_logger', path: '~/Epimorphics/shared/json-rails-logger'
  # gem 'lr_common_styles', path: '~/Epimorphics/clients/land-registry/projects/lr_common_styles'
  # gem 'qonsole_rails', path: '~/Epimorphics/clients/land-registry/projects/qonsole-rails'
end

source 'https://rubygems.pkg.github.com/epimorphics' do
  gem 'json_rails_logger'
  gem 'lr_common_styles'
  gem 'qonsole_rails'
end
