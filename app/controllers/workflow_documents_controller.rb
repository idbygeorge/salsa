class WorkflowDocumentsController < ApplicationController
  layout :set_layout
  before_action :get_organizations_if_supervisor
  before_action :require_staff_permissions, only: [:index]

  def index
    if session[:admin_authorized]
      @documents = Document.where.not(view_id: nil)
      return
    end
    org = get_org
    user_assignment = current_user.user_assignments.find_by organization_id: org.id
    if user_assignment && user_assignment.role == "staff"
      @documents = Document.where.not(view_id: nil).where(user_id: current_user.id)
    elsif user_assignment && user_assignment.role == "supervisor" && user_assignment.cascades
      @documents = Document.where.not(view_id: nil).where(organization_id: org.children.map(&:id) + [org.id]).order(:workflow_step_id)
    end
  end

  private
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
