include ApplicationHelper
class WorkflowMailer < ApplicationMailer
  helper :application
  def step_email document, user, organization, step_slug, allowed_variables
    orgs = organization.parents.push(organization)
    workflow_step = WorkflowStep.find_by(organization_id: orgs.map(&:id), slug: step_slug)
    next_workflow_step = WorkflowStep.find_by(id:workflow_step&.next_workflow_step_id)
    @next_component = Component.find_by(organization_id: orgs.map(&:id), slug: next_workflow_step.slug) if workflow_step&.next_workflow_step_id
    @mail_component = Component.find_by(organization_id: orgs.map(&:id), category: "mailer", slug: "#{next_workflow_step&.slug}_email", format: "liquid")
    if @mail_component
      @template = Liquid::Template.parse(@mail_component.layout)
      @subject = Liquid::Template.parse(@mail_component.subject).render(allowed_variables).html_safe
      @step_email = @template.render(allowed_variables).html_safe
      if @next_component && @next_component.role == "supervisor"
        users = document.assignees
        users.each do |user|
          mail(to: user.email, subject: @subject)
        end
        user = nil
      elsif @next_component && @next_component.role == "approver"
        user_ids = document.approvers_that_have_not_signed.map(&:whodunnit)
        user = document.closest_users_with_role("approver", user_ids).where(id:user_ids).first
      end
      mail(to: user&.email, subject: @subject) if !user.blank?
    end
  end

  def welcome_email document, user, organization, step_slug, allowed_variables
    orgs = organization.parents.push(organization)
    @mail_component = Component.find_by(organization_id: orgs.map(&:id),category: "mailer", slug: "#{step_slug}_email", format: "liquid")
    if @mail_component
      @template = Liquid::Template.parse(@mail_component.layout)
      @welcome_email = @template.render(allowed_variables).html_safe
      @subject = Liquid::Template.parse(@mail_component.subject).render(allowed_variables).html_safe
      mail(to: user.email, subject: @subject)
    end
  end
end
