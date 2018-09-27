class UserMailer < ApplicationMailer
  def welcome_email user, organization, allowed_variables
    allowed_variables["user_activation_url"] = "https://#{organization.slug}/admin/user_activation/#{user.activation_digest}"
    orgs = organization.parents.push(organization)
    @mail_component = Component.find_by(organization_id: orgs.map(&:id),category: "mailer", slug: "user_welcome_email", format: "liquid")
    if @mail_component
      @template = Liquid::Template.parse(@mail_component.layout)
      @welcome_email = @template.render(allowed_variables).html_safe
      @subject = Liquid::Template.parse(@mail_component.subject).render(allowed_variables).html_safe
      mail(to: user.email, subject: @subject)
    end
  end
  def new_unassigned_user_email user, organization, allowed_variables
    allowed_variables["activate_user_url"] = "https://#{organization.slug}/admin/user_activation/#{user.activation_digest}"
    orgs = organization.parents.push(organization)
    @mail_component = Component.find_by(organization_id: orgs.map(&:id),category: "mailer", slug: "new_unassigned_user_email", format: "liquid")
    if @mail_component
      @template = Liquid::Template.parse(@mail_component.layout)
      @new_unassigned_user_email = @template.render(allowed_variables).html_safe
      @subject = Liquid::Template.parse(@mail_component.subject).render(allowed_variables).html_safe
      mail_user = organization.user_assignments.find_by(role:"organization_admin")&.user
      mail_user = UserAssignment.find_by(role:"admin").user if mail_user.blank?
      mail(to: mail_user.email, subject: @subject)
    end
  end
end
