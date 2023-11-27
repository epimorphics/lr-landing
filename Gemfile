# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

gem 'haml-rails', '~> 2.0.0'
gem 'http_accept_language'
gem 'prometheus-client', '~> 4.0'
gem 'puma'
gem 'sentry-rails', '~> 5.2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'rubocop'
  gem 'rubocop-rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
end

# rubocop:disable Layout/LineLength
# TODO: While running the rails app locally for testing you can set gems to your local path
# ! These "local" paths do not work with a docker image - use the repo instead
# gem 'qonsole-rails', path: '~/Epimorphics/clients/land-registry/projects/qonsole-rails'
# gem 'json_rails_logger', '~> 1.0.0', path: '~/Epimorphics/shared/json-rails-logger/'
# gem 'lr_common_styles', '~> 1.9.3', path: '~/Epimorphics/clients/land-registry/projects/lr_common_styles/'
# rubocop:enable Layout/LineLength

# TODO: In production you want to set this to the gem from the epimorphics github repo
gem 'qonsole-rails', git: 'https://github.com/epimorphics/qonsole-rails'

# TODO: In production you want to set this to the gem from the epimorphics package repo
source 'https://rubygems.pkg.github.com/epimorphics' do
  gem 'json_rails_logger', '~> 1.0.0'
  gem 'lr_common_styles', '~> 1.9.3'
end
