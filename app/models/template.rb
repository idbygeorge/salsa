class Template < ActiveRecord::Base
  versioned

  belongs_to :organization
end
