class ComponentsController < ApplicationController
  layout 'components'

  before_filter :organizations

  def index
    @components = @organization.components

    @components = @components.where(category: params[:category]) if params[:category]
  end

  def new
    @component = Component.new
  end

  def create
    @component = Component.new component_params
    @component[:organization_id] = @organization[:id]

    @component.save!

    redirect_to components_path
  end

  def update
    @component = Component.find_by! slug: params[:slug], organization: @organization
    @component.update! component_params

    redirect_to components_path
  end

  def show
    edit
  end

  def edit
    @component = Component.find_by! slug: params[:slug], organization: @organization
  end

  private

  def organizations
    @organizations = Organization.all
    @organization = Organization.find_by slug: params[:organization_slug]
  end

  def component_params
    # ActionController::Parameters.action_on_unpermitted_parameters = :raise

    params.require(:component).permit(
      :name,
      :slug,
      :description,
      :category,
      :css,
      :js,
      :layout,
      :format,
      :gui_css,
      :gui_js,
      :gui_templates,
      :gui_controls,
      :gui_section_nav,
      :gui_help,
      :gui_example,
      :gui_footer,
      :gui_content_toolbar,
      :gui_header
    )
  end
end
