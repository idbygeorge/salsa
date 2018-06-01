Rails.application.routes.draw do

  root 'default#index'

  resources :documents, path: 'SALSA', constraints: { slug: /.*/ }

  get '/:alias/:document', to: redirect('/SALSA/%{document}'), constraints: { alias: /(syllabuses|salsas?)/ }
  get '/:alias/:document/:action', to: redirect('/SALSA/%{document}/%{action}'), constraints: { alias: /(syllabuses|salsas?)/, action: /(edit|template)?/ }
  
  get '/status/server', to: 'default#status_server'

  get '/admin', to: 'admin#landing', as: 'admin'

  namespace :admin do
    get "report", to: 'auditor#report', as: 'auditor_report'
    post "report", to: 'auditor#report', as: 'auditor_generate_report'
    get "download", to: 'auditor#download', as: 'auditor_download'

    get "report-status", to: 'auditor#reportStatus', as: 'auditor_report_status'
    get "archive-report", to: 'auditor#archive_report', as: 'auditor_archive_report'
    get "restore-report", to: 'auditor#restore_report', as: 'auditor_restore_report'
    get "reports", to: 'auditor#reports', as: 'auditor_reports'
  end

  scope 'admin' do
    get "search", to: 'admin#search', as: 'admin_search'
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

    get "organization/preview/:slug", to: 'republish#preview', as: 'republish_preview', constraints: { slug: /.*/ }
    get "organization/republish/:slug", to: 'republish#update_lock', as: 'republish_update', constraints: { slug: /.*/ }

    scope 'organization/:slug' do

      resources :components, param: :component_slug, constraints: { component_slug: /.*/, slug: /.+/ }
      resources :reports, param: :component_slug, constraints: { component_slug: /.*/, slug: /.+/ }
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
