Rails.application.routes.draw do

  root 'default#index'

  resources :documents, path: 'SALSA', constraints: { slug: /.*/ }

  get '/:alias/:document', to: redirect('/SALSA/%{document}'), constraints: { alias: /(syllabuses|salsas?)/ }
  get '/:alias/:document/:action', to: redirect('/SALSA/%{document}/%{action}'), constraints: { alias: /(syllabuses|salsas?)/, action: /(edit|template)?/ }

  get '/admin', to: 'admin#landing', as: 'admin'

  scope 'admin' do
    get "search", to: 'admin#search', as: 'admin_search'

    get "canvas", to: 'admin#canvas', as: 'admin_canvas'
    post "canvas", to: 'admin#canvas', as: 'generate_report'
    get "archive", to: 'admin#archive', as: 'admin_archive'
    get "download", to: 'admin#download', as: 'admin_download'

    get "report-status", to: 'admin#reportStatus', as: 'admin_report_status'
    get "reports", to: 'admin#reports', as: 'admin_reports'

    get "canvas/accounts", to: 'admin#canvas_accounts', as: 'canvas_accounts'
    post "canvas/accounts/sync", to: 'admin#canvas_accounts_sync', as: 'canvas_accounts_sync'
    get "canvas/courses", to: 'admin#canvas_courses', as: 'canvas_courses'
    post "canvas/courses/sync", to: 'admin#canvas_courses_sync', as: 'canvas_courses_sync'

    get "login/(:slug)", to: 'admin#login', as: 'admin_login', constraints: { slug: /.*/ }
    post "login/(:slug)", to: 'admin#authenticate', as: 'admin_authenticate', constraints: { slug: /.*/ }

    resources :users, as: 'admin_users', controller: 'admin_users'

    # user assignment routes
    post 'user/assignment', as: 'admin_user_assignments', to: 'admin_users#assign'
    patch 'user/assignment/:id', as: 'admin_update_user_assignments', to: 'admin_users#update_assignment'

    get 'user/remove_assignment/:id', as: 'admin_remove_assignment', to: 'admin_users#remove_assignment'
    get 'user/edit_assignment/:id', as: 'admin_edit_assignment', to: 'admin_users#edit_assignment'

    resources :documents, as: 'admin_document', controller: 'admin_documents'

    post "organizations/documents"

    get "organizations/import"

    get "logout", to: 'admin#logout', as: 'admin_logout'

    resources :organizations, param: :slug, constraints: { slug: /.*/ }

    scope 'organization/:organization_slug' do
      resources :components, param: :slug, constraints: { slug: /.*/, organization_slug: /.+/ }
      resources :reports, param: :slug, constraints: { slug: /.*/, organization_slug: /.+/ }
    end
  end

  get '/lms/courses', to: 'documents#course_list', as: 'lms_course_list'
  get '/lms/courses/:lms_course_id', to: 'documents#course', as: 'lms_course_document'
  get '/lms/courses/:lms_course_id/version/:version', to: 'documents#course', as: 'lms_course_document_history'



  get "canvas/list_courses"
  get "canvas/relink_courses"
  get "oauth2/login"
  get "oauth2/logout"
  get "oauth2/callback"
  get "default/maintenance"
  get "default/tos"
  get "default/faq"

  # get path: 'doc/:alias', constraints: { alias: /.+/ }, as: 'org_document_alias', controller: 'documents', action: 'alias'
  #
  # scope ':sub_organization_slugs' do
  #   get path: 'doc/:alias', constraints: { alias: /.+/, organization_slug: /.+/ }, as: 'sub_org_document_alias', controller: 'documents', action: 'alias'
  #   resources :documents, path: 'SALSA', constraints: { sub_organization_slugs: /.+/ }, as: 'sub_org_document'
  #   get '', to: 'default#index', constraints: { sub_organization_slugs: /.+/ }
  # end
end
