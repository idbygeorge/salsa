class WorkflowMailer < ApplicationMailer
  def step_email user, organization, step_slug, allowed_variables
    workflow_step = WorkflowStep.find_by(slug: step_slug)
    @mail_component = Component.find_by(category: "mailer", slug: "#{step_slug}_mailer", format: "liquid")
    @next_component = Component.find_by(slug: WorkflowStep.find(workflow_step&.next_workflow_step_id).slug) if workflow_step&.next_workflow_step_id
    if @mail_component
      @template = Liquid::Template.parse(@mail_component.layout)
      @subject = Liquid::Template.parse(@mail_component.description).render(allowed_variables).html_safe
      @step_email = @template.render(allowed_variables).html_safe
      user = user.find_by(organization.parents.find_by(level: @next_component&.organization_level)) if @next_component
      mail(to: user.email, subject: @subject)
    end
  end

  def welcome_email user, organization
    @component = Component.find_by(category: "mailer", slug: "welcome_email", format: "liquid")
    @template = Liquid::Template.parse(@component.layout)
    @welcome_email = @template.render({"user_name" => "#{user.name}","user_email" => "#{user.email}", "organization_name" => "#{organization.name}"})
    mail(to: user.email, subject: "Welcome to #{organization.name}")
  end
end
