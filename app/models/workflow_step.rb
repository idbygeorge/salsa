class WorkflowStep < ApplicationRecord
  validates :slug, presence: true
  validates :slug, uniqueness: true
  belongs_to :organization
  belongs_to :parent, :class_name => 'WorkflowStep'
  has_one :children, :class_name => 'WorkflowStep', :foreign_key => 'parent_id'
end
