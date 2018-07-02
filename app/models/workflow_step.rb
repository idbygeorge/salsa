class WorkflowStep < ApplicationRecord
  validates :slug, presence: true
  belongs_to :organization
end
