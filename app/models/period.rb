class Period < ApplicationRecord
  validates :slug, presence: true
  validates :start_date, presence: true
  validates :duration, presence: true
  validates :slug, uniqueness: { scope: :organization }
  validates_uniqueness_of :is_default, if: :is_default, scope: :organization, message: "is already set for this organization"

  belongs_to :organization
  has_many :documents

  def end_date
    self.start_date + self.duration.days if self.start_date && self.duration
  end

  def to_s
    return "#{self.slug} from organization: #{self.organization.slug} "
  end
end
