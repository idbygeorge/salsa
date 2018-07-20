class WorkflowMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @component = Component.find_by(section: "mailer")
    @template = Liquid::Template.parse(@component.layout)
    @template.render({user_name:"John Doe"})
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end
end
