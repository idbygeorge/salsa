class Organization < ActiveRecord::Base
  acts_as_nested_set

  has_many :documents
  has_many :components

  default_scope order('lft, rgt')
end