class Component < ApplicationRecord
  has_paper_trail

  belongs_to :organization
  validates_uniqueness_of :slug, :scope => :organization_id

  def to_param
    slug
  end
end
