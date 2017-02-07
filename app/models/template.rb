class Template < ApplicationRecord
  versioned

  belongs_to :organization
end
