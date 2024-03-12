# frozen_string_literal: true

Rails.application.routes.draw do
  mount QonsoleRails::Engine, at: '/qonsole'

  root 'landing#index'
  resources :landing, only: [:index]

  get 'landing/hpi', to: 'landing#hpi'
  get 'doc/hpi', to: 'doc#hpi', as: 'hpi_doc'
  get 'doc/ukhpi', to: redirect('/app/ukhpi/doc', status: 302)
  get 'app/doc/ppd', to: 'doc#ppd', as: 'ppd_doc'
  get 'doc/ppd', to: redirect('/app/doc/ppd', status: 301)
  get 'app/root/doc/ppd', to: redirect('app/doc/ppd', status: 301)
  get 'doc/ukhpi-dsd', to: redirect('/app/ukhpi/doc/ukhpi-dsd', status: 302)
  get 'doc/ukhpi-user-guide', to: redirect('/app/ukhpi/doc/ukhpi-user-guide', status: 302)
  get 'doc/accessibility', to: 'doc#accessibility'
  get 'doc/privacy', to: 'doc#privacy'
end
