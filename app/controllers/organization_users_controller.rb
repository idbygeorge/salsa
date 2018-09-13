class OrganizationUsersController < AdminUsersController
  skip_before_action :require_admin_permissions
  before_action :require_organization_admin_permissions, except:[:import_users,:create_users]
  before_action :require_supervisor_permissions, only:[:import_users,:create_users]

  def index
    @organization = Organization.all.select{ |o| o.full_slug == params[:slug] }.first
    page = 1
    page = params[:page] if params[:page]
    show_archived = params[:show_archived] == "true"
    user_ids = UserAssignment.where(organization_id: @organization.id).map(&:user_id)
    @users = User.where(id: user_ids, archived: show_archived).order('name', 'email').all.page(params[:page]).per(15)
    @session = session
  end

  def new
    @organization = Organization.find_by slug: params[:slug]
    @user = User.new
  end

  def create
    @organization = Organization.find_by slug: params[:slug]
    @user = User.new

    @user.attributes = user_params

    # unless @user.password
    #     @user.password = SecureRandom.urlsafe_base64
    #     @user.password_confirmation = @user.password
    # end

    if @user.save
      @user_assignment = UserAssignment.create(user_id:@user.id, organization_id:@organization.id ,role:"staff", cascades: true)
      return redirect_to polymorphic_path([params[:controller].singularize],id: @user.id)
    else
        flash[:error] = 'Error creating user'
        return render action: :new
    end
  end


  def remove_assignment
    @user_assignment = UserAssignment.find_by id: params[:id], organization_id: Organization.find_by(slug: params[:slug])
    return redirect_to organization_users_path if @user_assignment.blank?
    @user_assignment.destroy

    redirect_to polymorphic_path([params[:controller].singularize],id: @user_assignment.user_id)
  end

  def assign
    @user = User.find params[:user_assignment][:user_id]
    @user_assignment = UserAssignment.new user_assignment_params
    if !has_role("admin")
      @user_assignment.organization_id = get_org.id
    end
    get_organizations
    @user_assignments = @user.user_assignments if @user.user_assignments.count > 0
    @new_permission = @user_assignment
    respond_to do |format|
      if @user_assignment.save
        format.html { redirect_to admin_user_path id: @user[:id], notice: 'User Assignment was successfully created.' }
        format.json { render :show, status: :created, location: @user_assignment }
      else
        format.html { render :show }
        format.json { render json: @user_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit_assignment
    @organization = Organization.find_by slug: params[:slug]
    if !has_role("admin")
      @roles.delete("Global Administrator")
    end
    @user_assignment = UserAssignment.find_by id: params[:id], organization_id: Organization.find_by(slug: params[:slug])
    return redirect_to organization_users_path if @user_assignment.blank?
  end

  def show
    @organization = Organization.all.select{ |o| o.full_slug == params[:slug] }.first
    user_ids = UserAssignment.where(organization_id: @organization.id ).map(&:user_id)
    users = User.where(id: user_ids, archived: false)
    @user = users.find_by id: params[:id]
    return redirect_to organization_users_path if @user.blank?
    @user_assignments = @user.user_assignments.where(organization_id: @organization.id) if @user.user_assignments.count > 0

    @new_permission = @user.user_assignments.new
  end

  def edit
    @organization = Organization.find_by slug: params[:slug]
    user_ids = UserAssignment.where(organization_id: Organization.find_by(slug: params[:slug])).map(&:user_id)
    users = User.where(id: user_ids, archived: false)
    @user = users.find_by id: params[:id]
    return redirect_to organization_users_path if @user.blank?
  end

  def archive
    user_ids = UserAssignment.where(organization_id: Organization.find_by(slug: params[:slug])).map(&:user_id)
    users = User.where(id: user_ids)
    @user = users.find_by id: params["#{params[:controller].singularize}_id".to_sym]
    @user.update(archived: true)
    flash[:notice] = "#{@user.email} has been archived"
    return redirect_to polymorphic_path([params[:controller]])
  end

  def restore
    user_ids = UserAssignment.where(organization_id: Organization.find_by(slug: params[:slug])).map(&:user_id)
    users = User.where(id: user_ids)
    @user = users.find params["#{params[:controller].singularize}_id".to_sym]
    @user.update(archived: false)
    flash[:notice] = "#{@user.email} has been restored"
    return redirect_to polymorphic_path([params[:controller]])
  end

  def create_users
    org = Organization.all.select{ |o| o.full_slug == params[:slug] }.first
    users_emails = params[:users][:emails].gsub(/ */,'').split(/(\r\n|\n|,)/).delete_if {|x| x.match(/\A(\r\n|\n|,|)\z/) }
    user_errors = Array.new
    user_errors.push "Add emails to import users" if params[:users][:emails].blank?
    users_emails.each do |user_email|
      user = User.find_or_initialize_by(email: user_email)
      user.password = "#{rand(36**40).to_s(36)}" if !user&.password
      user.name = "New User" if !user&.name
      user.archived = false
      user.activated = false
      user_activation_token user
      user.save
      UserAssignment.create(role:"staff",user_id:user.id,organization_id:org.id,cascades:true) if user
      user.errors.messages.each do |error|
        user_errors.push "Could not create user with email: '#{user.email}' because: #{error[0]} #{error[1][0]}" if user.errors
      end
      next if !user.errors.empty?
      UserMailer.welcome_email(user,org,component_allowed_liquid_variables(nil,user,org)).deliver_later
    end
    flash[:notice] = "Users created successfully" if user_errors == [] && users_emails != []
    flash[:errors] = user_errors
    redirect_to organization_import_users_path
  end

  def import_users
    @organization = @organizations.all.select{ |o| o.full_slug == params[:slug] }.first
  end

end
