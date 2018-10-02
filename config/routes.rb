Rails.application.routes.draw do

  root 'default#index'
  scope '(*org_path)', constraints:{ org_path: /.*/ }, defaults: {org_path: nil} do
    devise_for :users, controllers: {
      sessions: 'users/sessions',
      saml_sessions: 'users/saml_sessions'
    }
    devise_scope :user do
      post '/auth/shibboleth', to: 'users/saml_sessions#create'
    end
    resources :documents, path: 'SALSA', constraints: { slug: /.*/ }
    scope 'workflow' do
      resources :documents, as: 'workflow_document', controller: 'workflow_documents'
      get "documents/:id/versions", as: 'workflow_document_versions', to: 'workflow_documents#versions'
      post "documents/:id/revert_document/:version_id", as: 'workflow_revert_document', to: 'workflow_documents#revert_document'
    end


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

    scope '/admin' do
      get "search", to: 'admin#search', as: 'admin_search'
      get "canvas/accounts", to: 'admin#canvas_accounts', as: 'canvas_accounts'
      post "canvas/accounts/sync", to: 'admin#canvas_accounts_sync', as: 'canvas_accounts_sync'
      get "canvas/courses", to: 'admin#canvas_courses', as: 'canvas_courses'
      post "canvas/courses/sync", to: 'admin#canvas_courses_sync', as: 'canvas_courses_sync'

      get "login/(:slug)", to: 'admin#login', as: 'admin_login', constraints: { slug: /.*/ }
      post "login/(:slug)", to: 'admin#authenticate', as: 'admin_authenticate', constraints: { slug: /.*/ }

      get "users_search", to: 'admin_users#users_search', as: 'admin_users_search'
      resources :users, as: 'admin_users', controller: 'admin_users' do
        post "archive"
        post "restore"
      end

      get "user_activation/:id", to: 'admin#user_activation', as: 'admin_user_activation'
      post "create_user/:id", to: 'admin#create_user', as: 'admin_create_user'

      # user assignment routes
      post 'user/assignment', as: 'admin_user_assignments', to: 'admin_users#assign'
      patch 'user/assignment/:id', as: 'admin_user_update_assignments', to: 'admin_users#update_assignment'


      get 'user/remove_assignment/:id', as: 'admin_user_remove_assignment', to: 'admin_users#remove_assignment'
      get 'user/edit_assignment/:id', as: 'admin_user_edit_assignment', to: 'admin_users#edit_assignment'

      resources :documents, as: 'admin_document', controller: 'admin_documents'
      get "documents/:id/versions", as: 'admin_document_versions', to: 'admin_documents#versions'
      post "documents/:id/revert_document/:version_id", as: 'admin_revert_document', to: 'admin_documents#revert_document'

      post "organizations/documents"

      get "organizations/import"

      get "logout", to: 'admin#logout', as: 'admin_logout'

      resources :organizations, :param => '*slug',only:[:index,:new,:create], format: false, constraints: { slug: /.*/ }
      get	"organizations/*slug/edit", controller:'organizations', action: 'edit', as: 'edit_organization', constraints: { slug: /.*/ }
    	get "organizations/*slug", controller:'organizations', action: 'show', as: 'organization', constraints: { slug: /.*/ }
    	patch "organizations/*slug", controller:'organizations', action: 'update', constraints: { slug: /.*/ }
      put	"organizations/*slug", controller:'organizations', action: 'update', constraints: { slug: /.*/ }
      delete	"organizations/*slug", controller:'organizations', action: 'delete', constraints: { slug: /.*/ }

      get "organization/preview/:slug", to: 'republish#preview', as: 'republish_preview', constraints: { slug: /.*/ }
      get "organization/republish/:slug", to: 'republish#update_lock', as: 'republish_update', constraints: { slug: /.*/ }

      scope '/organization/*slug', constraints: {slug: /.+/ } do
        resources :users, as: 'organization_users', controller: 'organization_users' do
          post "archive"
          post "restore"
        end

        get "users_search", to: 'organization_users#users_search', as: 'organization_users_search'

        post 'users/assignment', as: 'organization_user_assignments', to: 'organization_users#assign'
        patch 'users/:id/assignment/', as: 'organization_user_update_assignments', to: 'organization_users#update_assignment'

        get 'user/remove_assignment/:id', as: 'organization_user_remove_assignment', to: 'organization_users#remove_assignment'
        get 'user/edit_assignment/:id', as: 'organization_user_edit_assignment', to: 'organization_users#edit_assignment'

        get "import_users", to: 'organization_users#import_users', as: 'organization_import_users'
        post "import_users", to: 'organization_users#create_users', as: 'create_users'
        resources :periods
        resources :workflow_steps
        post 'start_workflow', to: 'organizations#start_workflow', as: 'start_workflow', action: "start_workflow"
        get 'start_workflow_form', to: 'organizations#start_workflow_form', as: 'start_workflow_form', action: "start_workflow_form"
        resources :components, param: :component_slug, constraints: { component_slug: /.*/ }
        get 'load_components', to: 'components#load_components', as: 'load_components'
        post 'import_components', to: 'components#import_components', as: 'import_components'
        get 'export_components', to: 'components#export_components', as: 'export_components'
        resources :reports, param: :component_slug, constraints: { component_slug: /.*/ }
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

    get '/:alias/:document', to: redirect('/SALSA/%{document}'), constraints: { alias: /(syllabuses|salsas?)/ }
    get '/:alias/:document/:action', to: redirect('/SALSA/%{document}/%{action}'), constraints: { alias: /(syllabuses|salsas?)/, action: /(edit|template)?/ }
  end
  get ":org_path", as: 'sub_root', to: 'default#index'

  # get path: 'doc/:alias', constraints: { alias: /.+/ }, as: 'org_document_alias', controller: 'documents', action: 'alias'
  #
  # scope ':sub_organization_slugs' do
  #   get path: 'doc/:alias', constraints: { alias: /.+/, organization_slug: /.+/ }, as: 'sub_org_document_alias', controller: 'documents', action: 'alias'
  #   resources :documents, path: 'SALSA', constraints: { sub_organization_slugs: /.+/ }, as: 'sub_org_document'
  #   get '', to: 'default#index', constraints: { sub_organization_slugs: /.+/ }
  # end
end
