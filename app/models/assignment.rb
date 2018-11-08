class Assignment < ApplicationRecord
  belongs_to :user, class_name: 'User'
  belongs_to :team_member, class_name: 'User'
end
