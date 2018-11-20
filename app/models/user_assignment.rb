class UserAssignment < ApplicationRecord
  def self.roles
    {'Global Administrator'=>'admin', 'Organization Administrator'=>'organization_admin', 'Auditor'=>'auditor', 'Designer'=>'designer', 'Supervisor'=>'supervisor','Staff'=>'staff','Approver'=>'approver'}
  end

  belongs_to :user
  belongs_to :organization, optional: true

  default_scope { order('user_id, organization_id, role') }

  validates :user_id, presence: true
  validates :role, presence: true
  validates :role, inclusion: {
    in: roles.values,
    message: "you cant create that role"
  }
  validates :user_id, uniqueness: {
    scope: :organization_id,
    message: "already has a role for the specified organization"
  }
  validates :organization_id, presence: true, unless: Proc.new { |ua| ua.role == 'admin' }

  def approvers
    ids = []
    self.organization.self_and_ancestors.each do |org|
      ids += org.user_assignments.where(role:["approver"]).where.not(user_id: self.user_id).pluck(:id)
    end
    return UserAssignment.where(id: ids)

  end

  def supervisors
    if self.role == "supervisor"
      user_assignments = UserAssignment.where(role: "supervisor",organization_id: self.organization.ancestors&.pluck(:id))
    else
      user_assignments = UserAssignment.where(role: "supervisor",organization_id: self.organization.self_and_ancestors&.pluck(:id))
    end
    user_assignments = user_assignments&.includes(:organization)&.reorder("organizations.depth DESC")
    org_id = user_assignments&.first&.organization_id
    return user_assignments.where(organization_id: org_id)
  end

  def workflow_roles
    ids = self.supervisors.pluck(:id) + self.approvers.pluck(:id)
    UserAssignment.where(id: ids)
  end

  def assignments
    if self.role == "approver" || self.role == "supervisor" || self.role == "organization_admin"
      UserAssignment.where(organization_id: self.organization.self_and_descendants,role: ["supervisor","staff"]).where.not(user_id:self.user_id)
    end

  end
end
