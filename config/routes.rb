Rails.application.routes.draw do
  mount QonsoleRails::Engine, at: "/qonsole"

  root "landing#index"
  resources :landing, only: [:index]

  get "documentation/hpi", to: "documentation#hpi", as: "hpi_doc"
  get "documentation/ppd", to: "documentation#ppd", as: "ppd_doc"
end
