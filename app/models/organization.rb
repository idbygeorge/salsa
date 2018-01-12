class Organization < ApplicationRecord
  acts_as_nested_set

  has_many :documents
  has_many :components

  default_scope { order('lft, rgt') }
  validates :slug, presence: true
  validates :name, presence: true
end
