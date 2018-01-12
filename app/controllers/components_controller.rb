class ComponentsController < ApplicationController
  layout 'components'

  before_action :require_organization_admin_permissions

  before_action :get_organizations
  before_action :get_organization

  def index
    @components = @organization.components

    available_component_formats

    @components = @components.where(category: params[:category]) if params[:category]

    @components = @components.where(format: @available_component_formats)
  end

  def new
    @component = Component.new

    available_component_formats
  end

  def create
    @component = Component.new component_params
    @component[:organization_id] = @organization[:id]

    available_component_formats

    if available_component_formats.include? @component.format
      if @component.valid?
        @component.save
        return redirect_to components_path
      end
    end

    flash[:error] = 'Error creating component'
    return render action: :new
  end

  def update
    available_component_formats

    @component = Component.find_by! slug: params[:component_slug], organization: @organization, format: @available_component_formats

    if available_component_formats.include? component_params[:format]
      if @component.valid?
        @component.update component_params
        return redirect_to components_path
      end
    end

    flash[:error] = 'Error creating component'
    render action: :new
  end

  def show
    edit
  end

  def edit
    available_component_formats
    @component = Component.find_by! slug: params[:component_slug], organization: @organization, format: @available_component_formats
  end

  private

  def get_organization
    @organization = Organization.find_by slug: params[:slug]
  end

  def available_component_formats
    if has_role('admin')
      @available_component_formats = ['html','erb','haml'];
    else
      @available_component_formats = ['html'];
    end
  end

  def component_params
    # ActionController::Parameters.action_on_unpermitted_parameters = :raise

    params.require(:component).permit(
      :name,
      :slug,
      :description,
      :category,
      :layout,
      :format,
    )
  end
end
