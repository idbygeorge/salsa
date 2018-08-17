class WorkflowMailer < ApplicationMailer
  def step_email user, organization, step_slug, allowed_variables
    orgs = organization.parents.push(organization)
    allowed_variables["workflow_documents_url"] = workflow_document_index_url(host: organization.slug)
    workflow_step = WorkflowStep.find_by(organization_id: orgs.map(&:id), slug: step_slug)
    @mail_component = Component.find_by(organization_id: orgs.map(&:id), category: "mailer", slug: "#{step_slug}_mailer", format: "liquid")
    @next_component = Component.find_by(organization_id: orgs.map(&:id), slug: WorkflowStep.find_by(organization_id: orgs.map(&:id), id:workflow_step&.next_workflow_step_id).slug) if workflow_step&.next_workflow_step_id
    if @mail_component
      @template = Liquid::Template.parse(@mail_component.layout)
      @subject = Liquid::Template.parse(@mail_component.subject).render(allowed_variables).html_safe
      @step_email = @template.render(allowed_variables).html_safe
      if @next_component && @next_component.role == "supervisor"
        orgs = organization.parents.push(organization).select { |org| org.level.to_i == @next_component&.role_organization_level.to_i }
        user = UserAssignment.find_by(organization_id: orgs.map(&:id) ,role:"supervisor").user
      end
      mail(to: user.email, subject: @subject)
    end
  end

  def welcome_email user, organization, step_slug, allowed_variables
    orgs = organization.parents.push(organization)
    allowed_variables["workflow_documents_url"] = workflow_document_index_url(host: organization.slug)
    @mail_component = Component.find_by(organization_id: orgs.map(&:id),category: "mailer", slug: "workflow_welcome_email", format: "liquid")
    if @mail_component
      @template = Liquid::Template.parse(@mail_component.layout)
      @welcome_email = @template.render(allowed_variables).html_safe
      @subject = Liquid::Template.parse(@mail_component.subject).render(allowed_variables).html_safe
      mail(to: user.email, subject: @subject)
    end
  end
end
