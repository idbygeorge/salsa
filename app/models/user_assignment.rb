class UserAssignment < ApplicationRecord
  def self.roles
    {'Global Administrator'=>'admin', 'Organization Administrator'=>'organization_admin', 'Auditor'=>'auditor', 'Designer'=>'designer', 'Supervisor'=>'supervisor','Staff'=>'staff'}
  end

  belongs_to :user
  belongs_to :organization, optional: true

  default_scope { order('user_id, organization_id, role') }

  validates :role, inclusion: {
    in: roles.values,
    message: "you cant create that role"
  }
  validates :user_id, uniqueness: {
    scope: :organization_id,
    message: "already has a role for the specified organization"
  }
  validates :organization_id, presence: true, unless: Proc.new { |ua| ua.role == 'admin' }

end
