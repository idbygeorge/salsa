Salsa::Application.routes.draw do
  get "organizations/list"
  get "organizations/create"
  get "organizations/edit"
  get "organizations/delete"
  get "organizations/show"
  root 'default#index'

  resources :syllabuses, :as => :salsas
  resources :salsas, :controller => "syllabuses", :as => 'syllabuses'

  get "canvas/list_courses"
  get "oauth2/login"
  get "oauth2/logout"
  get "oauth2/callback"
  get "default/maintenance"
  get "default/tos"
  get "default/faq"
end
