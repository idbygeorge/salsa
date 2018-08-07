class Document < ApplicationRecord
  has_paper_trail

  before_validation :normalize_blank_values, :ensure_ids

  belongs_to :organization
  belongs_to :component, optional: true
  belongs_to :workflow_step, optional: true
  belongs_to :user, optional: true

  validates :lms_course_id, uniqueness: { scope: :organization_id, message: "is already in use for this organization" }, allow_nil: true
  validates_uniqueness_of [:view_id, :edit_id, :template_id]

  def assigned_to? user
    result = false
    if self.workflow_step&.component_id && user != nil && self.workflow_step.step_type != "end_step"
      component = self.workflow_step.component
      user_assignment = user.user_assignments.find_by(organization_id:self.organization_id)
      user_org = user_assignment.organization
      if (component.role == nil || component.role == "") && user_assignment.role == "supervisor" && user_org.level == component.role_organization_level
        result = true
      elsif component.role == "staff" && user_assignment.role == "staff" && self.user_id == user.id && self.workflow_step_id != ""
        result = true
      elsif component.role == "supervisor" && user_assignment.role == "supervisor" && user_assignment.cascades && user_org.level <= component.role_organization_level
        result = true
      elsif component.role == "supervisor" && user_assignment.role == "supervisor" && !user_assignment.cascades && user_org.level == component.role_organization_level
        result = true
      else
        result = false
      end
    else
      result = false
    end
    result
  end

  def assignee
    if self.workflow_step_id
      component = self.workflow_step.component
      if component.role == "staff"
        self.user
      elsif component.role == "supervisor"
        uas = UserAssignment.find_by(organization_id: self.organization_id)
        User.find_by(user_assignment_id:ua.id)
      else
        nil
      end
    else
      nil
    end
  end

  def normalize_blank_values
    attributes.each do |column, value|
      self[column].present? || self[column] = nil
    end
  end

  def ensure_ids
    ids_match = nil
    counter = 0
    while ids_match != true && counter < 5 do
      counter += 1
      self.view_id = Document.generate_id unless view_id || ids_match == false
      self.edit_id = Document.generate_id unless edit_id || ids_match == false
      self.template_id = Document.generate_id unless template_id || ids_match == false
      unless Document.where(view_id: self.view_id).where.not(id: self.id).exists? || Document.where(edit_id: self.edit_id).where.not(id: self.id).exists? || Document.where(template_id: self.template_id).where.not(id: self.id).exists?
        ids_match = true
      else
        ids_match = false
      end
    end
  end

  def reset_ids
    self.view_id = Document.generate_id
    self.edit_id = Document.generate_id
    self.template_id = Document.generate_id
    self.lms_course_id = nil
  end

  protected

  def self.generate_id
    (0...30).map{ ('a'..'z').to_a[rand(26)] }.join
  end
end
