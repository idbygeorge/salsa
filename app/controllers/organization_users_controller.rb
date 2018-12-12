class OrganizationUsersController < AdminUsersController
  skip_before_action :require_admin_permissions
  before_action :redirect_to_sub_org, only:[:index,:new,:show,:edit,:import_users,:edit_assignment]
  before_action :require_admin_permissions, only: [:archive,:restore]
  before_action :require_supervisor_permissions

  def index
    @organization = find_org_by_path(params[:slug])
    user_ids = UserAssignment.where(organization_id: @organization.self_and_descendants.pluck(:id)).pluck(:user_id)

    super
  end

  def new
    @organization = find_org_by_path(params[:slug])

    super

  end

  def create
    @organization = find_org_by_path(params[:slug])

    super

    @user_assignment = UserAssignment.create(user_id:@user.id, organization_id:@organization.id ,role:"staff", cascades: true) if user_saved
  end

  def assign
    @organization = find_org_by_path(params[:slug])

    super
  end

  def edit_assignment
    @organization = find_org_by_path(params[:slug])

    super

    return redirect_to organization_users_path(org_path: params[:org_path]) if @user_assignment.blank?
  end

  def update_assignment
    @organization = find_org_by_path(params[:slug])

    super
  end

  def show
    @organization = find_org_by_path(params[:slug])
    user_ids = UserAssignment.where(organization_id: @organizations.pluck(:id) ).pluck(:user_id)
    users = User.where(id: user_ids, archived: false)
    @user = users.find_by id: params[:id]
    return redirect_to organization_users_path(org_path: params[:org_path]) if @user.blank?

    super
  end

  def edit
    @organization = find_org_by_path(params[:slug])
    user_ids = UserAssignment.where(organization_id: @organization&.id).pluck(:user_id)
    users = User.where(id: user_ids, archived: false)
    @user = users.find_by id: params[:id]&.to_i
    return redirect_to organization_users_path(org_path: params[:org_path]) if @user.blank?
  end

  def archive
    user_ids = UserAssignment.where(organization_id: find_org_by_path(params[:slug])).pluck(:user_id)
    users = User.where(id: user_ids)
    @user = users.find_by id: params["#{params[:controller].singularize}_id".to_sym].to_i
    @user.update(archived: true)
    flash[:notice] = "#{@user.email} has been archived"
    return redirect_to polymorphic_path([params[:controller]], org_path: params[:org_path])
  end

  def restore
    user_ids = UserAssignment.where(organization_id: find_org_by_path(params[:slug])).pluck(:user_id)
    users = User.where(id: user_ids)
    @user = users.find params["#{params[:controller].singularize}_id".to_sym].to_i
    @user.update(archived: false)
    flash[:notice] = "#{@user.email} has been activated"
    return redirect_to organization_user_edit_assignment_path(slug: params[:slug],id: @user.user_assignments.find_by(organization_id:find_org_by_path(params[:slug]).id).id)
  end

  def create_users
    org = @organizations.find_by(id: params[:users][:organization_id])
    org = find_org_by_path(params[:slug]) if org.blank?
    users_emails = params[:users][:emails].gsub(/ */,'').split(/(\r\n|\n|,)/).delete_if {|x| x.match(/\A(\r\n|\n|,|)\z/) }
    users_remote_ids = params[:users][:remote_user_ids].gsub(/ */,'').split(/(\r\n|\n|,)/).delete_if {|x| x.match(/\A(\r\n|\n|,|)\z/) }
    user_errors = Array.new
    users_created = 0
    user_errors.push "Add emails or remote user ids to import users" if params[:users][:emails].blank? && params[:users][:remote_user_ids].blank?
    users_remote_ids.each do |remote_user_id|
      ua = UserAssignment.where("lower(username) = ? ", remote_user_id.to_s.downcase).first
      user = ua&.user
      user = User.new() if user.blank?
      user.password = "#{rand(36**40).to_s(36)}" if !user&.password
      user.name = "New User" if !user&.name
      user.email = "#{remote_user_id}@example.com" if !user&.email
      user.archived = false
      user.activated = false if ua.blank?
      user.save
      ua = UserAssignment.create(username: remote_user_id, role:"staff",user_id: user.id, organization_id: org.id, cascades: true) if ua&.organization_id != org&.id
      user.errors.messages.each do |error|
        user_errors.push "Could not create user with remote user ID: '#{ua.username}' because: #{error[0]} #{error[1][0]}" if user.errors
      end
      next if !user.errors.empty?
      users_created +=1
    end
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
      users_created +=1
      UserMailer.welcome_email(user,org,component_allowed_liquid_variables(nil,user,org)).deliver_later
    end
    flash[:notice] = "#{users_created} Users created successfully" if users_created >= 1
    flash[:errors] = user_errors
    redirect_to organization_import_users_path(org_path: params[:org_path])
  end

  def import_users
    @organization = find_org_by_path(params[:slug])
  end

end
