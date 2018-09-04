class Organization < ApplicationRecord
  acts_as_nested_set

  has_many :documents
  has_many :components
  has_many :periods
  has_many :user_assignments
  has_many :workflow_steps

  default_scope { order('lft, rgt') }
  validates :slug, presence: true
  validates :slug, exclusion: { in: %w(status), message: "%{value} is reserved." }
  validates :name, presence: true

  def self.export_types
    ["default","Program Outcomes"]
  end
  validates :export_type, :inclusion=> { :in => self.export_types }

  def parents
    parents = []
    parent = self.parent
    while parent != nil do
      parents.push parent
      parent = parent.parent
    end
    return parents
  end

  def organization_ids
    org_ids = [self.id]
    if self.inherit_workflows_from_parents
      org_ids = self.parents.map{|x| x[:id]}
    end
    return org_ids
  end

  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end
