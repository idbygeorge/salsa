class WorkflowDocumentsController < ApplicationController
  layout :set_layout
  before_action :check_organization_workflow_enabled
  before_action :set_paper_trail_whodunnit, only: [:revert_document]
  before_action :get_organizations_if_supervisor
  before_action :require_staff_permissions, only: [:index]
  before_action :require_supervisor_permissions, except: [:index]

  def index
    org = get_org
    user_assignment = current_user.user_assignments.find_by organization_id: org.id if current_user
    @documents = Document.where(organization_id:org.id).where('documents.updated_at != documents.created_at')
    if has_role("supervisor") && params[:show_completed] == "true"
      @documents = @documents.where(workflow_step_id: WorkflowStep.where(step_type:"end_step").map(&:id) )
    elsif has_role("supervisor") && (params[:show_completed] == "false" || !params[:show_completed])
      @documents = @documents.where(workflow_step_id: WorkflowStep.where.not(step_type:"end_step").map(&:id) + [nil] )
    else
      @documents = get_documents(current_user, @documents)
    end
    @documents = @documents.page(params[:page]).per(params[:per])
  end

  def edit
    get_document params[:id]
    if @document.organization.inherit_workflows_from_parents
      @workflow_steps = WorkflowStep.where(organization_id: @document.organization.organization_ids + [@document.organization_id]).order(step_type: :desc)
    else
      @workflow_steps = WorkflowStep.where(organization_id: @document.organization_id, step_type: "start_step")
    end
  end

  def update
    get_document params[:id]
    if params[:document][:workflow_step_id] != @document.workflow_step_id && params[:document][:user_id] != nil
      wfs = WorkflowStep.find(params[:document][:workflow_step_id])
      if wfs.step_type == "start_step"
        user = User.find(params[:document][:user_id])
        WorkflowMailer.welcome_email(user,@organization,wfs.slug,component_allowed_liquid_variables(user,@document.organization,wfs)).deliver_later
      end
    end

    # if the publish target changed, clear out the published at date
    if params[:document][:lms_course_id] && @document[:lms_course_id] != params[:document][:lms_course_id] ||
       params[:document][:organization_id] && @document[:organization_id] != params[:document][:organization_id]
      @document[:lms_published_at] = nil
    end

    if @document.update document_params
      redirect_to workflow_document_index_path
    else
      flash[:error] = @document.errors.messages

      render 'edit'
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

  def document_params
    params.require(:document).permit(:name, :lms_course_id, :workflow_step_id, :user_id)
  end

  def get_documents user, documents
    docs = []
    documents.each_with_index do |document, index|
      if document.assigned_to? user
        docs.push document.id
      end
    end
    return Document.where(id: docs)
  end

  def get_document id=params[:id]
    @document = Document.find_by id: id
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
