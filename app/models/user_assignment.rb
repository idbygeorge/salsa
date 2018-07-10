class UserAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :organization, optional: true

  default_scope { order('user_id, organization_id, role') }

  validates :user_id, uniqueness: {
    scope: :organization_id,
    message: "already has a role for the specified organization"
  }
  validates :organization_id, presence: true, unless: Proc.new { |ua| ua == 'admin' }
end
