Rails.application.routes.draw do
  mount QonsoleRails::Engine, at: "/qonsole"

  root "landing#index"
  resources :landing, only: [:index]
end
