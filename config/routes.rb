Rails.application.routes.draw do

  devise_for :users
  root 'default#index'

  resources :documents, path: 'SALSA', constraints: { slug: /.*/ }
  scope 'workflow' do
    resources :documents, as: 'workflow_document', controller: 'workflow_documents'
    get "documents/:id/versions", as: 'workflow_document_versions', to: 'workflow_documents#versions'
    post "documents/:id/revert_document/:version_id", as: 'workflow_revert_document', to: 'workflow_documents#revert_document'
  end

  get '/:alias/:document', to: redirect('/SALSA/%{document}'), constraints: { alias: /(syllabuses|salsas?)/ }
  get '/:alias/:document/:action', to: redirect('/SALSA/%{document}/%{action}'), constraints: { alias: /(syllabuses|salsas?)/, action: /(edit|template)?/ }

  get '/status/server', to: 'default#status_server'

  get '/admin', to: 'admin#landing', as: 'admin'

  namespace :admin do
    resources :periods
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

    resources :users, as: 'admin_users', controller: 'admin_users' do
      post "archive"
      post "restore"
    end

    get "user_activation/:id", to: 'admin#user_activation', as: 'admin_user_activation'
    post "create_user/:id", to: 'admin#create_user', as: 'admin_create_user'

    # user assignment routes
    post 'user/assignment', as: 'admin_user_assignments', to: 'admin_users#assign'
    patch 'user/assignment/:id', as: 'admin_update_user_assignments', to: 'admin_users#update_assignment'

    get "import_users", to: 'admin_users#import_users', as: 'admin_import_users'
    post "import_users", to: 'admin_users#create_users', as: 'create_users'

    get 'user/remove_assignment/:id', as: 'admin_remove_assignment', to: 'admin_users#remove_assignment'
    get 'user/edit_assignment/:id', as: 'admin_edit_assignment', to: 'admin_users#edit_assignment'

    resources :documents, as: 'admin_document', controller: 'admin_documents'
    get "documents/:id/versions", as: 'admin_document_versions', to: 'admin_documents#versions'
    post "documents/:id/revert_document/:version_id", as: 'admin_revert_document', to: 'admin_documents#revert_document'

    post "organizations/documents"

    get "organizations/import"

    get "logout", to: 'admin#logout', as: 'admin_logout'

    resources :organizations, param: :slug, constraints: { slug: /.*/ }

    get "organization/preview/:slug", to: 'republish#preview', as: 'republish_preview', constraints: { slug: /.*/ }
    get "organization/republish/:slug", to: 'republish#update_lock', as: 'republish_update', constraints: { slug: /.*/ }

    scope 'organization/:slug' do
      resources :periods, constraints: {slug: /.+/ }
      resources :workflow_steps, constraints: { slug: /.+/ }
      post 'start_workflow', to: 'organizations#start_workflow', as: 'start_workflow', action: "start_workflow", constraints: { slug: /.+/ }
      get 'start_workflow_form', to: 'organizations#start_workflow_form', as: 'start_workflow_form', action: "start_workflow_form", constraints: { slug: /.+/ }
      resources :components, param: :component_slug, constraints: { component_slug: /.*/, slug: /.+/ }
      get 'load_components', to: 'components#load_components', as: 'load_components', constraints: { slug: /.+/ }
      post 'import_components', to: 'components#import_components', as: 'import_components', constraints: { slug: /.+/ }
      get 'export_components', to: 'components#export_components', as: 'export_components', constraints: { slug: /.+/ }
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
