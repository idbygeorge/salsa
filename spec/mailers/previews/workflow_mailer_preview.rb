# Preview all emails at http://localhost:3000/rails/mailers/workflow_mailer
class WorkflowMailerPreview < ActionMailer::Preview
  def step_email
    org = Organization.all.order(:depth).last
    orgs = org.parents.push(org)
    user = User.first
    wfs = WorkflowStep.where(organization_id: orgs.pluck(:id), step_type: "start_step").first
    step_slug = wfs.slug
    doc = Document.create(user_id: user.id, organization_id: orgs.pluck(:id),workflow_step_id: wfs.id)
    allowed_variables = {"user_name" => "#{user&.name}","user_email" => "#{user&.email}", "organization_name" => "#{org&.name}", "step_slug" => "#{step_slug}", "document_url" => "http://localhost:3000/SALSA/#{doc.edit_id}"}
    WorkflowMailer.step_email(doc, user,org,step_slug, allowed_variables)
  end

  def welcome_email
    org = Organization.all.order(:depth).last
    orgs = org.parents.push(org)
    user = User.first
    wfs = WorkflowStep.where(organization_id: orgs.pluck(:id)).first
    step_slug = wfs.slug
    doc = Document.create(user_id: user.id, organization_id: orgs.pluck(:id),workflow_step_id: wfs.id)
    allowed_variables = {"user_name" => "#{user&.name}","user_email" => "#{user&.email}", "organization_name" => "#{org&.name}", "step_slug" => "#{step_slug}", "document_url" => "http://localhost:3000/SALSA/#{doc.edit_id}"}
    WorkflowMailer.welcome_email(doc, user,org,step_slug, allowed_variables)
  end
end
