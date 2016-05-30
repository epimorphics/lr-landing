Rails.application.routes.draw do
  mount QonsoleRails::Engine, at: "/qonsole"
end
