class UserMailer < ApplicationMailer
  def welcome_email user, organization
    @component = Component.find_by(category: "mailer", slug: "welcome_email", format: "liquid")
    @template = Liquid::Template.parse(@component.layout)
    @welcome_email = @template.render({"user_name" => "#{user.name}","user_email" => "#{user.email}", "organization_name" => "#{organization.name}"})
    mail(to: user.email, subject: "You have been invited to join #{organization.name} on SALSA")
  end
end
