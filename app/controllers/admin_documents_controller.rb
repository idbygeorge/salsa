class AdminDocumentsController < AdminDocumentsBaseController
  before_action :get_organizations, only: [:new, :edit, :update, :index, :versions]
  before_action :require_designer_permissions
  before_action :require_admin_permissions, only: [:index]
  before_action :set_paper_trail_whodunnit

  layout 'admin'

  def index
    @documents = Document.where.not(view_id: nil).reorder(created_at: :desc).page(params[:page]).per(params[:per])
  end

  def new
    @document = Document.new
  end

  private

  def get_document id=params[:id]
    @document = Document.find(id)
    raise('Insufficent permissions for this document') unless has_role('designer', @document.organization)
  end
end
