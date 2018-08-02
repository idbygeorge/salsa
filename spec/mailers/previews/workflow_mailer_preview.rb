# Preview all emails at http://localhost:3000/rails/mailers/workflow_mailer
class WorkflowMailerPreview < ActionMailer::Preview
  def step_email
    org = Organization.first
    user = User.first
    step_slug = WorkflowStep.where(organization_id: org.id).first.slug
    allowed_variables = {"user_name" => "#{user&.name}","user_email" => "#{user&.email}", "organization_name" => "#{org&.name}", "step_slug" => "#{step_slug}"}
    WorkflowMailer.step_email(user,org,step_slug, allowed_variables)
  end
end
user = User.find(38)
doc = Document.find_by(edit_id:"rfulccpxtpyahzdyplrydgxrlljmlp")
doc.assigned_to? user
