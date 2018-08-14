class Period < ApplicationRecord
  validates :slug, presence: true
  belongs_to :organization
  has_many :documents
end
