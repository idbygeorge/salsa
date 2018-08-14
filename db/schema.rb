# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180813215552) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "components", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "description"
    t.string "category"
    t.integer "organization_id"
    t.text "css"
    t.text "js"
    t.text "layout"
    t.text "format"
    t.text "gui_css"
    t.text "gui_js"
    t.text "gui_templates"
    t.text "gui_controls"
    t.text "gui_section_nav"
    t.text "gui_help"
    t.text "gui_example"
    t.text "gui_footer"
    t.text "gui_content_toolbar"
    t.text "gui_header"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "role"
    t.integer "role_organization_level"
    t.string "subject"
    t.index ["category"], name: "index_components_on_category"
    t.index ["organization_id"], name: "index_components_on_organization_id"
    t.index ["slug", "organization_id"], name: "index_components_on_slug_and_organization_id", unique: true
  end

  create_table "document_meta", id: :serial, force: :cascade do |t|
    t.integer "document_id"
    t.string "key"
    t.string "value"
    t.string "lms_organization_id"
    t.string "lms_course_id"
    t.integer "root_organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "edit_id"
    t.string "view_id"
    t.text "payload"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "template_id"
    t.integer "organization_id"
    t.string "lms_course_id"
    t.datetime "lms_published_at"
    t.integer "component_id"
    t.integer "component_version"
    t.string "term_id"
    t.integer "version"
    t.integer "workflow_step_id"
    t.integer "user_id"
    t.integer "period_id"
    t.index ["component_id"], name: "index_documents_on_component_id"
    t.index ["edit_id"], name: "index_documents_on_edit_id", unique: true
    t.index ["lms_course_id"], name: "index_documents_on_lms_course_id"
    t.index ["organization_id"], name: "index_documents_on_organization_id"
    t.index ["template_id"], name: "index_documents_on_template_id", unique: true
    t.index ["term_id"], name: "index_documents_on_term_id"
    t.index ["view_id"], name: "index_documents_on_view_id", unique: true
  end

  create_table "failed_jobs", id: false, force: :cascade do |t|
    t.integer "priority"
    t.datetime "run_at"
    t.bigint "job_id"
    t.text "job_class"
    t.json "args"
    t.integer "error_count"
    t.text "last_error"
    t.text "queue"
  end

  create_table "organization_meta", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "key"
    t.string "value"
    t.string "lms_organization_id"
    t.integer "root_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.integer "depth"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "lms_authentication_source"
    t.string "lms_authentication_id"
    t.string "lms_authentication_key"
    t.string "lms_info_slug"
    t.string "lms_id"
    t.datetime "dashboard_start_at"
    t.datetime "dashboard_end_at"
    t.string "home_page_redirect"
    t.json "default_account_filter"
    t.datetime "republish_at"
    t.string "republish_batch_token"
    t.boolean "skip_lms_publish"
    t.boolean "enable_anonymous_actions", default: true
    t.boolean "track_meta_info_from_document"
    t.string "export_type", default: "default"
    t.boolean "enable_workflows"
    t.boolean "inherit_workflows_from_parents"
    t.integer "default_workflow_step_id"
    t.index ["depth"], name: "index_organizations_on_depth"
    t.index ["lft"], name: "index_organizations_on_lft"
    t.index ["lms_id"], name: "index_organizations_on_lms_id"
    t.index ["parent_id"], name: "index_organizations_on_parent_id"
    t.index ["rgt"], name: "index_organizations_on_rgt"
    t.index ["slug", "parent_id"], name: "index_organizations_on_slug_and_parent_id", unique: true
  end

  create_table "periods", id: :serial, force: :cascade do |t|
    t.string "slug"
    t.string "name"
    t.integer "organization_id"
    t.datetime "start_date"
    t.integer "duration"
    t.string "cycle"
    t.integer "sequence"
    t.boolean "is_default"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["slug", "organization_id"], name: "index_periods_on_slug_and_organization_id", unique: true
  end

  create_table "que_jobs", primary_key: ["queue", "priority", "run_at", "job_id"], force: :cascade, comment: "3" do |t|
    t.integer "priority", limit: 2, default: 100, null: false
    t.datetime "run_at", default: -> { "now()" }, null: false
    t.bigserial "job_id", null: false
    t.text "job_class", null: false
    t.json "args", default: [], null: false
    t.integer "error_count", default: 0, null: false
    t.text "last_error"
    t.text "queue", default: "", null: false
  end

  create_table "report_archives", id: :serial, force: :cascade do |t|
    t.text "payload"
    t.datetime "generating_at"
    t.integer "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json "report_filters"
    t.boolean "is_archived", default: false
    t.index ["organization_id"], name: "index_report_archives_on_organization_id"
  end

  create_table "templates", id: :serial, force: :cascade do |t|
    t.string "slug"
    t.text "payload"
    t.integer "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["slug", "organization_id"], name: "index_templates_on_slug_and_organization_id", unique: true
  end

  create_table "user_assignments", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "organization_id"
    t.string "username"
    t.boolean "cascades"
    t.string "role"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "email"
    t.string "password_digest"
    t.string "remember_digest"
    t.string "activation_digest"
    t.boolean "activated"
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.boolean "archived", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "vestal_versions", id: :serial, force: :cascade do |t|
    t.string "versioned_type"
    t.integer "versioned_id"
    t.string "user_type"
    t.integer "user_id"
    t.string "user_name"
    t.text "modifications"
    t.integer "number"
    t.integer "reverted_from"
    t.string "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["created_at"], name: "index_vestal_versions_on_created_at"
    t.index ["number"], name: "index_vestal_versions_on_number"
    t.index ["tag"], name: "index_vestal_versions_on_tag"
    t.index ["user_id", "user_type"], name: "index_vestal_versions_on_user_id_and_user_type"
    t.index ["user_name"], name: "index_vestal_versions_on_user_name"
    t.index ["versioned_id", "versioned_type"], name: "index_vestal_versions_on_versioned_id_and_versioned_type"
  end

  create_table "workflow_steps", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.integer "organization_id"
    t.integer "next_workflow_step_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "component_id"
    t.string "step_type", default: "default_step"
  end

end
