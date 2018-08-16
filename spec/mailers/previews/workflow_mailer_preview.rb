# Preview all emails at http://localhost:3000/rails/mailers/workflow_mailer
class WorkflowMailerPreview < ActionMailer::Preview
  def step_email
    org = Organization.first
    orgs = org.parents.push(org)
    user = User.first
    step_slug = WorkflowStep.where(organization_id: orgs.map(&:id)).first.slug
    allowed_variables = {"user_name" => "#{user&.name}","user_email" => "#{user&.email}", "organization_name" => "#{org&.name}", "step_slug" => "#{step_slug}"}
    WorkflowMailer.step_email(user,org,step_slug, allowed_variables)
  end

  def welcome_email
    org = Organization.find(3)
    orgs = org.parents.push(org)
    user = User.first
    step_slug = WorkflowStep.where(organization_id: orgs.map(&:id)).first.slug
    allowed_variables = {"user_name" => "#{user&.name}","user_email" => "#{user&.email}", "organization_name" => "#{org&.name}", "step_slug" => "#{step_slug}"}
    WorkflowMailer.welcome_email(user,org,step_slug, allowed_variables)
  end
end
