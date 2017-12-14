class Template < ApplicationRecord
  has_paper_trail

  belongs_to :organization
end
