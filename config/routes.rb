Rails.application.routes.draw do
  mount QonsoleRails::Engine, at: "/qonsole"

  root "landing#index"
  resources :landing, only: [:index]

  get "doc/hpi", to: "doc#hpi", as: "hpi_doc"
  get "doc/ukhpi", to: "doc#ukhpi", as: "ukhpi_doc"
  get "doc/ppd", to: "doc#ppd", as: "ppd_doc"
end
