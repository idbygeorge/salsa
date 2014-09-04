Salsa::Application.routes.draw do
  root 'default#index'

  resources :documents, path: 'SALSA', constraints: { slug: /.*/ }

  get '/:alias/:document', to: redirect('/SALSA/%{document}'), constraints: { alias: /(syllabuses|salsas?)/ }
  get '/:alias/:document/:action', to: redirect('/SALSA/%{document}/%{action}'), constraints: { alias: /(syllabuses|salsas?)/, action: /(edit|template)?/ }

  scope 'admin' do
    resources :documents, as: 'admin_document', controller: 'admin_documents'

    post "organizations/documents"
    get "logout", to: 'organizations#logout'

    resources :organizations, param: :slug, constraints: { slug: /.*/ }

    scope 'organization/:organization_slug' do
      resources :components, param: :slug, constraints: { slug: /.*/, organization_slug: /.+/ }
    end
  end

  get '/lms/courses', to: 'documents#course_list', as: 'lms_course_list'
  get '/lms/courses/:lms_course_id', to: 'documents#course', as: 'lms_course_document'
  get '/lms/courses/:lms_course_id/version/:version', to: 'documents#course', as: 'lms_course_document_history'



  get "canvas/list_courses"
  get "oauth2/login"
  get "oauth2/logout"
  get "oauth2/callback"
  get "default/maintenance"
  get "default/tos"
  get "default/faq"

  scope ':sub_organization_slugs' do
    resources :documents, path: 'SALSA', constraints: { sub_organization_slugs: /.+/ }, as: 'sub_org_document'
    get '', to: 'default#index', constraints: { sub_organization_slugs: /.+/ }
  end
end
