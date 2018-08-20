# Preview all emails at http://localhost:3000/rails/mailers/workflow_mailer
class WorkflowMailerPreview < ActionMailer::Preview
  def step_email
    org = Organization.find(2)
    orgs = org.parents.push(org)
    user = User.first
    wfs = WorkflowStep.where(organization_id: orgs.map(&:id)).first
    step_slug = wfs.slug
    doc = Document.create(user_id: user.id, organization_id: orgs.map(&:id),workflow_step_id: wfs.id)
    allowed_variables = {"user_name" => "#{user&.name}","user_email" => "#{user&.email}", "organization_name" => "#{org&.name}", "step_slug" => "#{step_slug}"}
    WorkflowMailer.step_email(doc, org.slug, user,org,step_slug, allowed_variables)
  end

  def welcome_email
    org = Organization.find(2)
    orgs = org.parents.push(org)
    user = User.first
    wfs = WorkflowStep.where(organization_id: orgs.map(&:id)).first
    step_slug = wfs.slug
    doc = Document.create(user_id: user.id, organization_id: orgs.map(&:id),workflow_step_id: wfs.id)
    allowed_variables = {"user_name" => "#{user&.name}","user_email" => "#{user&.email}", "organization_name" => "#{org&.name}", "step_slug" => "#{step_slug}"}
    WorkflowMailer.welcome_email(doc, org.slug, user,org,step_slug, allowed_variables)
  end
end
