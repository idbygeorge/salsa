class WorkflowDocumentsController < ApplicationController
  layout :set_layout
  before_action :check_organization_workflow_enabled
  before_action :set_paper_trail_whodunnit, only: [:revert_document]
  before_action :get_organizations_if_supervisor
  before_action :require_staff_permissions, only: [:index]
  before_action :require_supervisor_permissions, only: [:versions, :revert_document]

  def index
    org = get_org
    user_assignment = current_user.user_assignments.find_by organization_id: org.id if current_user
    @documents = get_documents(current_user, Document.where(organization_id: org.id)).page(params[:page]).per(params[:per])
  end

  def versions
    get_document params[:id]
    if session[:admin_authorized] || has_role('admin')
      @document_versions = @document.versions.where(event: "update")
    else
      @document_versions = @document.versions.where("object ~ ?",".*organization_id: #{get_org.id}.*").where(event: "update")
    end
  end

  def revert_document
    get_document params[:id]
    @document = @document.versions.find(params[:version_id]).reify
    @document.save
  end

  private

  def get_documents user, documents
    documents.each do |document|
      if !document.assigned_to? user
        documents = documents.drop(document.id)
      end
    end
    return Document.where(id: documents.map(&:id))
  end

  end
  def get_document id=params[:id]
    @document = Document.find_by id: id
  end

  def get_organizations_if_supervisor
    if has_role('supervisor')
      get_organizations
    end
  end

  def set_layout
    if has_role('supervisor')
      return 'admin'
    else
      return 'workflow'
    end
  end
