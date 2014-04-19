class Organization < ActiveRecord::Base
  acts_as_nested_set

  has_many :syllabuses
end