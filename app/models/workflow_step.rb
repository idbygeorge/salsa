class WorkflowStep < ApplicationRecord
  validate :not_end_step_and_next_step
  validates :slug, presence: true
  validates :slug, format: { with: /\A[a-zA-Z0-9\-_]+\Z/, message: "only allows letters, numers, _ and -" }
  validates :slug, uniqueness: { scope: :organization_id, message: "is already in use for this organization" }, allow_nil: false
  validates :next_workflow_step_id, uniqueness: { scope: :organization_id, message: "is already in use for this organization" }, allow_nil: true
  belongs_to :role, optional: true
  belongs_to :organization, optional: true
  belongs_to :component, optional: true
  validate :step_type_valid
  belongs_to :next_step, :class_name => 'WorkflowStep', optional: true
  has_one :previous_step, :class_name => 'WorkflowStep', :foreign_key => 'parent_id'
  has_many :documents
  has_many :organizations

  def self.step_types
    step_types = ["start_step","end_step","default_step"]
  end

  def self.workflows organization_ids
    workflows = []
    wf_steps = WorkflowStep.where(step_type: "start_step", organization_id: organization_ids)
    wf_steps.each do |wf_step|
      wf_done = false
      workflow = []
      workflow.push wf_step
      next_wf_step_id = wf_step.next_workflow_step_id
      wf_done = true if next_wf_step_id == nil
      while wf_done != true do
        wfs = WorkflowStep.find(next_wf_step_id)
        workflow.push wfs
        next_wf_step_id = wfs.next_workflow_step_id
        if wfs.step_type == "end_step" || wfs.next_workflow_step_id == nil
          wf_done = true
        end
      end
      workflows.push workflow
    end
      return workflows
  end

  def not_end_step_and_next_step
    h = @attributes.to_h
    if h.fetch("next_workflow_step_id") !=nil && h.fetch("step_type") == "end_step"
      errors.add(:next_workflow_step_id, "cant have a next workflow step id if end_step is selected")
      errors.add(:step_type, 'cant have end step selected if there is a next workflow step id')

      return
    end
  end

  def previous_step
    WorkflowStep.find_by(self.id)
  end

  def to_s
    return "#{self.slug} from organization: #{self.organization.slug} "
  end

  def step_type_valid
    WorkflowStep.step_types.include?(self.step_type)
  end
end
