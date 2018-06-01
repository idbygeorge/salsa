class Organization < ApplicationRecord
  acts_as_nested_set

  has_many :documents
  has_many :components

  default_scope { order('lft, rgt') }
  validates :slug, presence: true
  validates :slug, exclusion: { in: %w(status), message: "%{value} is reserved." }
  validates :name, presence: true
end
