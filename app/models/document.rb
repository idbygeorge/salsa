class Document < ActiveRecord::Base
  versioned

  before_save [:normalize_blank_values, :ensure_ids]

  belongs_to :organization
  belongs_to :component

  validates :lms_course_id, uniqueness: { scope: :organization_id, message: "is already in use for this organization" }, allow_nil: true
  validates_uniqueness_of [:view_id, :edit_id, :template_id]

  def normalize_blank_values
    attributes.each do |column, value|
      self[column].present? || self[column] = nil
    end
  end

	def ensure_ids
		self.view_id = Document.generate_id unless view_id
    self.edit_id = Document.generate_id unless edit_id
    self.template_id = Document.generate_id unless template_id
	end

  def reset_ids
    self.view_id = Document.generate_id
    self.edit_id = Document.generate_id
    self.template_id = Document.generate_id
  end

	protected

	def self.generate_id
		(0...30).map{ ('a'..'z').to_a[rand(26)] }.join
	end
end
