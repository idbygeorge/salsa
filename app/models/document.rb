class Document < ApplicationRecord
  has_paper_trail

  before_validation :normalize_blank_values, :ensure_ids

  belongs_to :organization
  # belongs_to :component, optional: true
  belongs_to :period, optional: true
  belongs_to :workflow_step, optional: true
  belongs_to :user, optional: true

  validates :lms_course_id, uniqueness: { scope: :organization_id, message: "is already in use for this organization" }, allow_nil: true
  validates_uniqueness_of [:view_id, :edit_id, :template_id]

  def assigned_to? user
    result = false
    if self.assignees&.include?(user)
      result = true
    end
    result
  end

  def assignees
    if self.workflow_step_id
      component = self.workflow_step&.component
      return nil if component.blank?
      if component.role == "staff"
        User.where(id: self.user_id)
      elsif component.role == "supervisor" && self.user&.user_assignments&.find_by(organization_id:self.organization_id)&.role == "staff"
        User.where(id: self.closest_roles("supervisor").pluck(:user_id))
      elsif component.role == "supervisor"
        User.where(id: self.closest_roles("supervisor", nil, false).pluck(:user_id))
      elsif component.role == "approver"
        user_ids = self.approvers_that_have_not_signed.pluck(:id)
        User.where(id: self.closest_user_with_role("approver", user_ids)&.id)
      else
        []
      end
    else
      []
    end

  end

  #TODO fix approver permissions with assignments
  def closest_roles(role, user_ids=nil, with_current_org=true)
    if user_assignees = self.user&.assignees&.where(role:role) && user_assignees != nil
      return user_assignees
    end

    if with_current_org
      org_ids = self.organization&.self_and_ancestors&.pluck(:id)
    else
      org_ids = self.organization&.ancestors&.pluck(:id)
    end

    user_assignments = UserAssignment.all
    user_assignments = user_assignments.where(user_id: user_ids) if !user_ids.blank?
    user_assignments = user_assignments&.where(role: role,organization_id: org_ids)&.includes(:organization)&.reorder("organizations.depth DESC")
    org_id = user_assignments&.first&.organization_id
    return user_assignments.where(organization_id: org_id)
  end

  def closest_role(role, user_ids=nil)
    if ua = self.user&.assignees&.find_by(role: role)
      return ua
    end
    user_assignments = UserAssignment.all
    user_assignments = user_assignments.where(user_id: user_ids) if !user_ids.blank?
    return user_assignments.where(role: role,organization_id: self.organization&.self_and_ancestors&.pluck(:id)).includes(:organization).reorder("organizations.depth DESC").first
  end

  # Find closest user with role
  def closest_user_with_role(role, user_ids=nil)
    self.closest_role(role, user_ids)&.user
  end

  # Find all users on the closest organization with the role
  def closest_users_with_role role, user_ids=nil
    return User.where(id: self.closest_roles(role,user_ids).pluck(:user_id))
  end

  def approvers
    orgs = self.organization.parents + [self.organization]
    approvers_array = []
    orgs.each do |org|
      approvers_array += org.user_assignments.where(role: "approver").pluck(:user_id)
    end
    if assignees = self.user&.assignees&.where(role: "approver")
      approvers_array += assignees.where(role: "approver").pluck(:user_id)
    end

    return User.where(id: approvers_array)
  end

  def approvers_that_signed
    self.approvers.where(id: self.versions.where(event:"publish",whodunnit: self.approvers.pluck(:id)).pluck(:whodunnit))
  end

  def approvers_that_have_not_signed
    self.approvers.where.not(id: self.versions.where(event:"publish",whodunnit: self.approvers.pluck(:id)).pluck(&:whodunnit))
  end

  def signed_by_all_approvers
    result = true
    self.approvers.each do |user|
      result = false if self.versions.where(event:"publish",whodunnit: user[:id]).blank?
    end
    result
  end

  def normalize_blank_values
    attributes.each do |column, value|
      self[column].present? || self[column] = nil
    end
  end

  def ensure_ids
    ids_match = nil
    counter = 0
    while ids_match != true && counter < 5 do
      counter += 1
      self.view_id = Document.generate_id unless view_id || ids_match == false
      self.edit_id = Document.generate_id unless edit_id || ids_match == false
      self.template_id = Document.generate_id unless template_id || ids_match == false
      unless Document.where(view_id: self.view_id).where.not(id: self.id).exists? || Document.where(edit_id: self.edit_id).where.not(id: self.id).exists? || Document.where(template_id: self.template_id).where.not(id: self.id).exists?
        ids_match = true
      else
        ids_match = false
      end
    end
  end

  def reset_ids
    self.view_id = Document.generate_id
    self.edit_id = Document.generate_id
    self.template_id = Document.generate_id
    self.lms_course_id = nil
  end

  protected

  def self.generate_id
    (0...30).map{ ('a'..'z').to_a[rand(26)] }.join
  end
end
