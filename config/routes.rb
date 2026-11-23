# frozen_string_literal: true

Rails.application.routes.draw do
  get 'qonsole', to: 'qonsole#index'
  # The engine's form submitted to /qonsole/query; keep any links to it working
  get 'qonsole/query', to: redirect { |_params, request| "qonsole?#{request.query_string}".chomp('?') }

  root 'landing#index'
  resources :landing, only: [:index]

  get 'landing/hpi', to: 'landing#hpi'
  get 'doc/hpi', to: 'doc#hpi', as: 'hpi_doc'
  get 'doc/ukhpi', to: redirect('/app/ukhpi/doc', status: 302)
  get 'doc/ppd', to: 'doc#ppd', as: 'ppd_doc'
  get 'doc/ukhpi-dsd', to: redirect('/app/ukhpi/doc/ukhpi-dsd', status: 302)
  get 'doc/ukhpi-user-guide', to: redirect('/app/ukhpi/doc/ukhpi-user-guide', status: 302)
  get 'accessibility', to: 'doc#accessibility'
  get 'privacy', to: 'doc#privacy'

  get '*unmatched_route', to: 'application#render_404'
end
