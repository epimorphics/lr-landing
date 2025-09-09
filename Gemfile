# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails'

# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
# gem 'uglifier'
gem 'terser' # Updating to terser for ES6+ support

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'get_process_mem'
gem 'haml-rails'
gem 'http_accept_language'
gem 'jbuilder'
gem 'prometheus-client'
gem 'puma'
gem 'puma-metrics'
gem 'sentry-rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'rubocop'
  gem 'rubocop-rails'
end

group :development do
  gem 'ruby-lsp'
  gem 'solargraph'
  # Devtools panel for Rails development - loading from the GitHub repo
  # (https://github.com/dejan/rails_panel/issues/209#issuecomment-2621877079_)
  gem 'meta_request', github: 'dejan/rails_panel', ref: 'meta_request-v0.8.5'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
end

source 'https://rubygems.pkg.github.com/epimorphics' do
  gem 'json_rails_logger'
  gem 'lr_common_styles'
  gem 'qonsole_rails', '=2.1.0'
end

# TODO: While running the rails app locally for testing you can set gems to your local path
# ! These "local" paths do not work with a docker image - use the repo instead
# gem 'json_rails_logger', path: '~/Epimorphics/shared/json-rails-logger'
# gem 'lr_common_styles', path: '~/Epimorphics/clients/land-registry/projects/lr_common_styles'
# gem 'qonsole_rails', path: '~/Epimorphics/clients/land-registry/projects/qonsole-rails'
