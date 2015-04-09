class Component < ActiveRecord::Base
  versioned

  belongs_to :organization

  def to_param
    slug
  end
end
