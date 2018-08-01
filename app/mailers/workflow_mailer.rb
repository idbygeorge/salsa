class WorkflowMailer < ApplicationMailer
  def step_email user, organization, step_slug
    workflow_step = WorkflowStep.find_by(slug: step_slug)
    @mail_component = Component.find_by(category: "mailer", slug: "#{step_slug}_email", format: "liquid")
    @next_component = Component.find_by(category: "mailer", slug: workflow_step.next_workflow_step.slug)
    if @mail_component
      @template = Liquid::Template.parse(@component.layout)
      @step_email = @template.render({"user_name" => "#{user.name}","user_email" => "#{user.email}", "organization_name" => "#{organization.name}", "step_slug" => "#{step_slug}"}).html_safe
      user = user.find_by(organization.parents.find_by(level: next_component.organization_level))
      mail(to: user.email, subject: "you have been assigned to #{step_slug} on #{user.name}'s review document'")
    end
  end

  def welcome_email user, organization
    @component = Component.find_by(category: "mailer", slug: "welcome_email", format: "liquid")
    @template = Liquid::Template.parse(@component.layout)
    @welcome_email = @template.render({"user_name" => "#{user.name}","user_email" => "#{user.email}", "organization_name" => "#{organization.name}"})
    mail(to: user.email, subject: "Welcome to #{organization.name}")
  end
end
