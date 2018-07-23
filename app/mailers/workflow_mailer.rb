class WorkflowMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email user, organization
    @component = Component.find_by(category: "mailer", slug: "welcome_email")
    @template = Liquid::Template.parse(@component.layout)
    @welcome_email = @template.render({"user" => user, "organization" => organization, })
    mail(to: "keith@ferney.org", subject: "Welcome to #{organization.name}")
  end
end
