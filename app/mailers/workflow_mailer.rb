include ApplicationHelper
class WorkflowMailer < ApplicationMailer
  helper :application
  def step_email document, user, organization, step_slug, allowed_variables
    orgs = organization.parents.push(organization)
    workflow_step = WorkflowStep.find_by(organization_id: orgs.map(&:id), slug: step_slug)
    @mail_component = Component.find_by(organization_id: orgs.map(&:id), category: "mailer", slug: "#{step_slug}_email", format: "liquid")
    @next_component = Component.find_by(organization_id: orgs.map(&:id), slug: WorkflowStep.find_by(organization_id: orgs.map(&:id), id:workflow_step&.next_workflow_step_id).slug) if workflow_step&.next_workflow_step_id
    if @mail_component
      @template = Liquid::Template.parse(@mail_component.layout)
      @subject = Liquid::Template.parse(@mail_component.subject).render(allowed_variables).html_safe
      @step_email = @template.render(allowed_variables).html_safe
      if @next_component && @next_component.role == "supervisor"
        user = UserAssignment.where(role: "supervisor",organization_id: document&.organization&.parents&.map(&:id)).includes(:organization).reorder("organizations.depth DESC").first&.user
      end
      mail(to: user&.email, subject: @subject)
    end
  end

  def welcome_email document, user, organization, step_slug, allowed_variables
    orgs = organization.parents.push(organization)
    debugger
    @mail_component = Component.find_by(organization_id: orgs.map(&:id),category: "mailer", slug: "#{step_slug}_email", format: "liquid")
    if @mail_component
      @template = Liquid::Template.parse(@mail_component.layout)
      @welcome_email = @template.render(allowed_variables).html_safe
      @subject = Liquid::Template.parse(@mail_component.subject).render(allowed_variables).html_safe
      mail(to: user.email, subject: @subject)
    end
  end
end
