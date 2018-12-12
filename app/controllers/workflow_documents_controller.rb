class WorkflowDocumentsController < AdminDocumentsBaseController
  #skip designer permissions from admin_controller
  skip_before_action :require_designer_permissions

  before_action :redirect_to_sub_org, only:[:index,:edit,:versions]
  layout :set_layout
  before_action :check_organization_workflow_enabled
  before_action :set_paper_trail_whodunnit, only: [:revert_document]
  before_action :get_organizations_if_supervisor
  before_action :require_staff_permissions, only: [:index]
  before_action :require_supervisor_permissions, except: [:index]

  def index
    org = get_org
    user_assignment = current_user.user_assignments.find_by organization_id: org.id if current_user
    @workflow_steps = WorkflowStep.where(organization_id: org.organization_ids.push(org.id))
    if has_role("supervisor") && params[:show_completed] == "true"
      @documents = Document.where(organization_id:org.descendants.pluck(:id)).where('documents.updated_at != documents.created_at')
      @documents = @documents.where(workflow_step_id: WorkflowStep.where(step_type:"end_step").pluck(:id) )
    elsif has_role("supervisor") && (params[:show_completed] == "false")
      @documents = Document.where(organization_id: org.descendants.pluck(:id)).where('documents.updated_at != documents.created_at')
      @documents = @documents.where(workflow_step_id: WorkflowStep.where.not(step_type:"end_step").pluck(:id) + [nil] )
    elsif has_role("supervisor") && params[:step_filter]
      @documents = Document.where(organization_id:org.descendants.pluck(:id)).where('documents.updated_at != documents.created_at')
      wfs = @workflow_steps.find_by(id: params[:step_filter].to_i)
      @documents = @documents.where(workflow_step_id: wfs&.id )
    else
      user_ids = []

      ua_user_ids = current_user.user_assignments&.find_by(organization_id: org.id)&.assignments&.pluck(:user_id)
      user_ids += ua_user_ids if ua_user_ids !=nil
      a_user_ids = current_user&.assignments&.pluck(:user_id)
      user_ids += a_user_ids if a_user_ids !=nil

      component_ids = Component.where(role: ["staff","supervisor"]).pluck(:id)
      workflow_step_ids = WorkflowStep.includes(:component).where(component: component_ids).where.not(step_type: "end_step").pluck(:id)

      period = Period.where(organization_id: org.self_and_ancestors.pluck(:id)).find_by(is_default: true)

      @staff_documents = Document.where(period_id: period&.id,user_id: user_ids, organization_id: org.id, workflow_step_id: workflow_step_ids).reorder(updated_at: :desc).page(params[:page]).per(params[:per])
      # where.not( workflow_step: { step_type: "end_step" })

      @documents = Document.where(organization_id:org.self_and_descendants.pluck(:id).push(org.id)).where('documents.updated_at != documents.created_at')

      @user_documents = @documents.where(user_id: current_user&.id) if current_user
      @documents = get_documents(current_user, @documents).reorder(updated_at: :asc)
      @user_documents = @user_documents.where.not(id: @documents.pluck(:id)).reorder(updated_at: :desc).page(params[:page]).per(params[:per]) if @user_documents
    end
    @documents = @documents.reorder(created_at: :asc).page(params[:page]).per(params[:per])
  end

  def update
    get_document params[:id]
    # if the publish target changed, clear out the published at date
    if params[:document][:workflow_step_id] != @document.workflow_step_id && !params[:document][:workflow_step_id].blank? && !params[:document][:user_id].blank?
      @wfs = WorkflowStep.find(params[:document][:workflow_step_id])
      if @wfs.step_type == "start_step"
        @user = User.find_by(id: params[:document][:user_id], archived: false)
        WorkflowMailer.welcome_email(@document, @user, @organization, @wfs.slug, component_allowed_liquid_variables(@document.workflow_step,User.find(params[:document][:user_id]),@organization, @document)).deliver_later
      end
    end
    super
  end

  private

  def get_documents user, documents
    document_ids = []
    documents.each_with_index do |document, index|
      if document.assigned_to? user
        document_ids.push document.id
      end
    end
    return Document.where(id: document_ids)
  end

  def get_organizations_if_supervisor
    if has_role('supervisor')
      get_organizations
      @organization = get_org
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
