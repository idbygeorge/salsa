class Syllabus < ActiveRecord::Base

	before_create :ensure_ids

	def ensure_ids
		self.view_id = Syllabus.generate_id unless view_id
    self.edit_id = Syllabus.generate_id unless edit_id
    self.template_id = Syllabus.generate_id unless template_id
	end

  def reset_ids
    self.view_id = Syllabus.generate_id
    self.edit_id = Syllabus.generate_id
    self.template_id = Syllabus.generate_id
  end

	protected

	def self.generate_id
		(0...30).map{ ('a'..'z').to_a[rand(26)] }.join
	end
end
