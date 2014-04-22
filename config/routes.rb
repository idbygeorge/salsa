Salsa::Application.routes.draw do
  root 'default#index'

  resources :documents, path: 'SALSA'

  get '/:alias/:document', to: redirect('/SALSA/%{document}'), constraints: { alias: /(syllabuses|salsas?)/ }
  get '/:alias/:document/:action', to: redirect('/SALSA/%{document}/%{action}'), constraints: { alias: /(syllabuses|salsas?)/, action: /(edit|template)?/ }

  resources :organizations

  post "organizations/documents"

  get "canvas/list_courses"
  get "oauth2/login"
  get "oauth2/logout"
  get "oauth2/callback"
  get "default/maintenance"
  get "default/tos"
  get "default/faq"
end
