class Component < ApplicationRecord
  versioned

  belongs_to :organization
  validates_uniqueness_of :slug, :scope => :organization_id

  def to_param
    slug
  end
end
