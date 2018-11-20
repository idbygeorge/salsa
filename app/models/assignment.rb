class Assignment < ApplicationRecord
  belongs_to :user, class_name: 'User'
  alias_attribute :manager, :user
  belongs_to :team_member, class_name: 'User'

  validates :role, uniqueness: { scope: [:team_member, :user] }
end
