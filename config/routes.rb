Rails.application.routes.draw do
  mount QonsoleRails::Engine, at: "/qonsole"

  root "landing#index"
  resources :landing, only: [:index]

  get "landing/hpi", to: "landing#hpi"
  get "doc/hpi", to: "doc#hpi", as: "hpi_doc"
  get "doc/ukhpi", to: "doc#ukhpi", as: "ukhpi_doc"
  get "doc/ppd", to: "doc#ppd", as: "ppd_doc"
  get "doc/ukhpi-dsd", to: "doc#ukhpi_dsd"
  get 'doc/ukhpi-user-guide', to: 'doc#ukhpi_user_guide'
end
