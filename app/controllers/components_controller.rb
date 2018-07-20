class ComponentsController < ApplicationController
  layout 'components'

  before_action :require_organization_admin_permissions

  before_action :get_organizations
  before_action :get_organization
  before_action :get_organization_levels
  before_action :get_roles

  def index
    @components = @organization.components

    available_component_formats

    @components = @components.where(category: params[:category]) if params[:category]

    @components = @components.where(format: @available_component_formats).order(:name, :slug)
  end

  def new
    @component = Component.new
    @valid_slugs = valid_slugs(@component.slug)

    available_component_formats
  end

  def create
    @component = Component.new component_params
    @valid_slugs = valid_slugs(@component.slug)
    @component[:organization_id] = @organization[:id]

    available_component_formats
    if available_component_formats.include? @component.format
      if @component.valid?
        if valid_slug?(params[:slug])
          @component.save
          return redirect_to components_path, notice: "Component was successfully created."
        else
          flash[:error] = "Invalid Slug"
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
    @valid_slugs = valid_slugs(@component.slug)

    if available_component_formats.include? component_params[:format]
      if @component.valid? && valid_slug?(@component.slug) == true
        @component.update component_params
        return redirect_to components_path, notice: "Component was successfully updated."
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
    @valid_slugs = valid_slugs(@component.slug)
  end

  private

  def valid_slug? component_slug
    if has_role('admin') || valid_slugs(component_slug).include?(component_params[:slug])
      true
    else
      false
    end
  end

  def valid_slugs component_slug
    if action_name == "new"
      ['salsa', 'section_nav', 'control_panel', 'footer', 'dynamic_content_1', 'dynamic_content_2', 'dynamic_content_3']
    else
      [component_slug, 'salsa', 'section_nav', 'control_panel', 'footer', 'dynamic_content_1', 'dynamic_content_2', 'dynamic_content_3']
    end
  end

  def get_organization
    @organization = Organization.find_by slug: params[:slug]
  end

  def get_organization_levels
     organization_levels = @organization.parents.map(&:level) + [@organization.level] + @organization.children.map(&:level)
     @organization_levels = organization_levels.sort
  end
  def available_component_formats
    if has_role('admin')
      @available_component_formats = ['html','erb','haml','liquid'];
    else
      @available_component_formats = ['html','liquid'];
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
      :role,
      :role_organization_level
    )
  end
end
