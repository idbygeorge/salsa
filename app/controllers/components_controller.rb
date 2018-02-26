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
    @valid_slugs = valid_slugs

    available_component_formats
  end

  def create
    @component = Component.new component_params
    @valid_slugs = valid_slugs
    @component[:organization_id] = @organization[:id]

    available_component_formats

    if available_component_formats.include? @component.format
      if @component.valid?
        if valid_slug
          @component.save
          return redirect_to components_path
        else
          flash[:error] = "invalid_slug"
          return render action: :new
        end
      end
    end

    flash[:error] = 'Error creating component'
    return render action: :new
  end

  def update
    available_component_formats

    @component = Component.find_by! slug: params[:component_slug], organization: @organization, format: @available_component_formats
    @valid_slugs = valid_slugs

    if available_component_formats.include? component_params[:format]
      if @component.valid? && valid_slug == true
        @component.update component_params
        return redirect_to components_path
      end
    end

    flash[:error] = 'Error updating component'
    render action: :new
  end

  def show
    edit
  end

  def edit
    available_component_formats
    @component = Component.find_by! slug: params[:component_slug], organization: @organization, format: @available_component_formats
    @valid_slugs = valid_slugs
  end

  private

  def valid_slug
    if has_role('admin') || @valid_slugs.include?(component_params[:slug])
      true
    else
      false
    end
  end

  def valid_slugs
    if action_name == "new"
      ['salsa', 'section_nav', 'control_panel', 'footer', 'dynamic_content_1', 'dynamic_content_2', 'dynamic_content_3']
    else
      [@component.slug, 'salsa', 'section_nav', 'control_panel', 'footer', 'dynamic_content_1', 'dynamic_content_2', 'dynamic_content_3']
    end
  end

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
