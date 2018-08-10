class Component < ApplicationRecord
  has_paper_trail

  has_many :workflow_steps
  belongs_to :organization
  validates_uniqueness_of :slug, :scope => :organization_id
  validates :role, inclusion: {in: UserAssignment.roles.values, message: "you cant create that role", :allow_blank => true}

  def to_param
    slug
  end
end
