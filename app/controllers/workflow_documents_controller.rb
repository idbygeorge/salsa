class WorkflowDocumentsController < ApplicationController
  layout :set_layout
  before_action :check_organization_workflow_enabled
  before_action :set_paper_trail_whodunnit, only: [:revert_document]
  before_action :get_organizations_if_supervisor
  before_action :require_staff_permissions, only: [:index]
  before_action :require_supervisor_permissions, only: [:versions, :revert_document]

  def index
    if session[:admin_authorized]
      @documents = Document.page(params[:page]).per(params[:per]).where.not(view_id: nil)
      return
    end
    org = get_org
    user_assignment = current_user.user_assignments.find_by organization_id: org.id
    if user_assignment && user_assignment.role == "staff"
      @documents = Document.page(params[:page]).per(params[:per]).where.not(view_id: nil).where(user_id: current_user.id)
    elsif user_assignment && has_role("supervisor") && user_assignment.cascades
      @documents = Document.page(params[:page]).per(params[:per]).where.not(view_id: nil).where(organization_id: org.children.map(&:id) + [org.id]).order(:workflow_step_id)
    elsif user_assignment && has_role("supervisor")
      @documents = Document.page(params[:page]).per(params[:per]).where.not(view_id: nil).where(organization_id: org.id).order(:workflow_step_id)
    end
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
end
