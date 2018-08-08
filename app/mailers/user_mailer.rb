class UserMailer < ApplicationMailer
  def welcome_email user, organization, allowed_variables
    allowed_variables["user_activation_link"] = "https://#{organization.slug}/admin/user_activation/#{user.activation_digest}"
    orgs = organization.parents.push(organization)
    @mail_component = Component.find_by(organization_id: orgs.map(&:id),category: "mailer", slug: "user_welcome_email", format: "liquid")
    if @mail_component
      @template = Liquid::Template.parse(@mail_component.layout)
      @welcome_email = @template.render(allowed_variables)
      @subject = Liquid::Template.parse(@mail_component.subject).render(allowed_variables).html_safe
      mail(to: user.email, subject: @subject)
    end
  end
end
