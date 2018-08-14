class Period < ApplicationRecord
  validates :slug, presence: true
  validates :slug, uniqueness: { scope: :organization }
  validates_uniqueness_of :is_default, if: :is_default, scope: :organization, message: "is already set for this organization"

  belongs_to :organization
  has_many :documents
end
