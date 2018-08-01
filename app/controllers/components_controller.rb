class ComponentsController < ApplicationController
  layout 'components'

  before_action :require_organization_admin_permissions
  before_action :require_admin_permissions, only: [:load_components, :export_components, :import_components]

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

  def export_components
    @components = @organization.components
    zipfile_path = "#{ENV["ZIPFILE_FOLDER"]}/#{@organization.slug}_components.zip"
    if File.exist?(zipfile_path)
      File.delete(zipfile_path)
    end
    Zip::File.open(zipfile_path, Zip::File::CREATE) do |zipfile|
      @components.each do |component|
        if component.format == "erb"
          zipfile.get_output_stream("#{component.name}.html.#{component.format}"){ |os| os.write component.layout }
        else
          zipfile.get_output_stream("#{component.name}.#{component.format}"){ |os| os.write component.layout }
        end
      end
    end
    send_file (zipfile_path)
  end

  def import_components
    Zip::File.open(params[:file].path) do |zipfile|
      zipfile.each do |file|
        content = file.get_input_stream.read
        Component.create(
          organization_id: @organization.id,
          name: file.name.delete(".html.erb"),
          slug: file.name[1..-1].delete(".html.erb"),
          description: "",
          category: "document",
          layout: content,
          format: File.extname(file.name).delete('.')
        )
      end
    end
    return redirect_to components_path, notice: "Imported Components"
  end

  def load_components
    org = @organization
    file_paths = Dir.glob("app/views/instances/default/*.erb")
    file_paths.each do |file_path|
      Component.create(
        organization_id: org.id,
        name: File.basename(file_path, ".html.erb"),
        slug: File.basename(file_path, ".html.erb")[1..-1],
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
    org = get_org
    slugs = ['salsa', 'section_nav', 'control_panel', 'footer', 'dynamic_content_1', 'dynamic_content_2', 'dynamic_content_3', 'welcome_email']
    if action_name != "new"
      slugs.push component_slug
    end
    if org.enable_workflows
      wfsteps = WorkflowStep.where(organization_id: org.organization_ids+[org.id])
      slugs += wfsteps.map(&:slug).map! {|x| x + "_mailer" }
    end
    return slugs.delete_if { |a| org.components.map(&:slug).include?(a) }
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
