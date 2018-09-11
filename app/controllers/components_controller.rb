class ComponentsController < ApplicationController
  layout 'components'

  before_action :require_organization_admin_permissions
  before_action :require_admin_permissions, only: [:load_components, :export_components, :import_components]

  before_action :get_organizations
  before_action :get_organization
  before_action :get_organization_levels
  before_action :get_roles

  def index
    @available_liquid_variables = component_allowed_liquid_variables true
    @components = @organization.components

    available_component_formats

    @components = @components.where(category: params[:category]) if params[:category]

    @components = @components.where(format: @available_component_formats).order(:name, :slug)
  end

  def new
    @component = Component.new
    @valid_slugs = valid_slugs(@component.slug)
    @available_liquid_variables = component_allowed_liquid_variables true
    available_component_formats
  end

  def create

    @available_liquid_variables = component_allowed_liquid_variables true
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
    @available_liquid_variables = component_allowed_liquid_variables true
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
    @available_liquid_variables = component_allowed_liquid_variables true
    edit
  end

  def edit
    @available_liquid_variables = component_allowed_liquid_variables true
    available_component_formats
    @component = Component.find_by! slug: params[:component_slug], organization: @organization, format: @available_component_formats
    @valid_slugs = valid_slugs(@component.slug)
  end

  def export_components
    @components = @organization.components
    zipfile_path = "#{ENV["ZIPFILE_FOLDER"]}/#{@organization.slug}_components.zip"
    if File.exist?(zipfile_path)
      File.delete(zipfile_path)
    end
    Zip::File.open(zipfile_path, Zip::File::CREATE) do |zipfile|
      @components.each do |component|
        if component.format == "erb"
          zipfile.get_output_stream("#{component.slug}.html.#{component.format}"){ |os| os.write component.layout }
        else
          zipfile.get_output_stream("#{component.slug}.#{component.format}"){ |os| os.write component.layout }
        end
      end
    end
    send_file (zipfile_path)
  end

  def import_components
    if !params[:file]
      flash[:error] = "You must select a file before importing components"
      return redirect_to components_path
    end
    Zip::File.open(params[:file].path) do |zipfile|
      zipfile.each do |file|
        content = file.get_input_stream.read
        component = Component.find_or_initialize_by(
          organization_id: @organization.id,
          slug: file.name.remove(/\..*/, /\b_/).gsub(/ /, '_')
        )
        if params[:overwrite] == "true" || component.new_record?
          component.category = "document" if component.category.blank?
          component.category = "mailer" if File.extname(file.name).delete('.') == "liquid"
          component.update(
            name: file.name.remove(/\..*/),
            description: "",
            layout: content,
            format: File.extname(file.name).delete('.')
          )
        end
      end
    end
    return redirect_to components_path, notice: "Imported Components"
  end

  def load_components
    org = @organization
    file_paths = Dir.glob("app/views/instances/default/*.erb")
    file_paths.each do |file_path|
        component = Component.find_or_initialize_by(
          organization_id: @organization.id,
          slug: File.basename(file_path).remove(/\..*/, /\b_/).gsub(/ /, '_'),
        )
        component.update(
          name: File.basename(file_path).remove(/\..*/),
          description: "",
          category: "document",
          layout: File.read(file_path),
          format: File.extname(file_path).delete('.')
        )
    end
    return redirect_to components_path, notice: "Loaded Default Components"
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
    org = get_organization
    slugs = ['salsa', 'section_nav', 'control_panel', 'footer', 'dynamic_content_1', 'dynamic_content_2', 'dynamic_content_3', 'user_welcome_email']
    if org.enable_workflows
      wfsteps = WorkflowStep.where(organization_id: org.organization_ids+[org.id])
      slugs += wfsteps.map(&:slug).map! {|x| x + "_mailer" }
      slugs.push "workflow_welcome_email"
    end
    slugs.delete_if { |a| org.components.map(&:slug).include?(a) }
    if action_name != "new"
      slugs.push component_slug
    end
    return slugs
  end

  def get_organization
    @organization = Organization.all.select{ |org| org.full_slug == params[:slug] }.first
  end

  def get_organization_levels
     @orgs = @organization.parents.push(@organization) + @organization.descendants
     organization_levels = @orgs.map { |h| h.slice(:slug, :level).values }
     @organization_levels = organization_levels.sort {|a,b|  a[1] <=> b[1] }
  end

  def available_component_formats
    if has_role('admin')
      @available_component_formats = ['html','erb','haml','liquid',nil];
    else
      @available_component_formats = ['html','liquid',nil];
    end
  end

  def component_params
    # ActionController::Parameters.action_on_unpermitted_parameters = :raise

    params.require(:component).permit(
      :name,
      :slug,
      :description,
      :category,
      :subject,
      :layout,
      :format,
      :role
    )
  end
end
