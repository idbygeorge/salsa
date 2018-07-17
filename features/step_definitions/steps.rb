Given(/^that I am logged in as a (\w+) on the organization$/) do |role|
  visit "/admin/login"
  @current_user = create(:user)
  user_assignment = create(:user_assignment, user_id: @current_user.id, role: role, organization_id: @organization.id)
  fill_in "user_email", :with => @current_user.email
  fill_in "user_password", :with => @current_user.password
  click_button("Log in")
  expect(page).to have_content("Logged in successfully")
end

Given(/^that I am logged in as a (\w+)$/) do |role|
  visit "/admin/login"
  @current_user = create(:user)
  user_assignment = create(:user_assignment, user_id: @current_user.id, role: role)
  fill_in "user_email", :with => @current_user.email
  fill_in "user_password", :with => @current_user.password
  click_button("Log in")
  expect(page).to have_content("Logged in successfully")
end

Given(/^there is a (\w+) on the organization$/) do |class_name|
  record = create(class_name, organization_id: @organization.id)
  instance_variable_set("@#{class_name}",record)
end

Given(/^there are (\d+) (\w+) for the organization/) do | number, class_name|
  record = create(class_name.singularize, organization: @organization)
  instance_variable_set("@#{class_name}",record)
end

Given(/^there is a (\w+) with a (\w+) of (\w+)$/) do |class_name, field, value|
  record = create(class_name, feild => value)
  instance_variable_set("@#{class_name}",record)
end

Given(/^there is a (\w+)$/) do |class_name|
  case class_name
  when /workflow/
    recordA = create(:workflow_step, slug:Faker::Types.unique.rb_string, end_step: true, organization_id: @organization.id)
    recordB = create(:workflow_step, slug:Faker::Types.unique.rb_string, next_workflow_step_id: recordA.id, organization_id: @organization.id)
    recordC = create(:workflow_step, slug:Faker::Types.unique.rb_string, next_workflow_step_id: recordB.id, organization_id: @organization.id)
    recordD = create(:workflow_step, slug:Faker::Types.unique.rb_string, next_workflow_step_id: recordC.id, start_step: true, organization_id: @organization.id)
    @workflows = WorkflowStep.workflows(@organization.id)
  else
    record = create(class_name)
    instance_variable_set("@#{class_name}",record)
  end
end

Given(/^there is a user with the role of (\w+)/) do |role|
  user = create(:user, email: Faker::Internet.free_email)
  user_assignment = create(:user_assignment, user_id: user.id, role: role, organization_id: @organization.id)
  instance_variable_set("@user",user)
end

Given("there are documents with document_metas that match the filter") do
  doc = create(:document, organization_id: @organization.id)
end

Given("there is a document with the first step in the workflow and assigned to the user") do
  @document = create(:document, workflow_step_id: @workflows.first.first.id, user_id: @current_user.id)
end

Given("the reports are generated") do
    params = {
      "account_filter" => "FL17",
      "controller" => "admin",
      "action" => "canvas"
    }
  report = create(:report_archive, organization_id: @organization.id, report_filters: params, generating_at: Time.now)
  ReportHelper.generate_report(@organization.slug, "FL17", params, report.id)
  sleep 1
  visit "/admin/reports"
  expect(page).to have_content("FL17")
end

Given("I am on the admin reports page for organization") do
  visit "/admin/reports"
  expect(page).to have_content("Reports for")
end

When(/^I click the "(.*?)" link$/) do |string|
  case string
  when /Edit Component/
    click_on("edit_#{@component.slug}")
  else
    save_page
    click_link(string)
  end
end

When(/^I click on "(.*?)"$/) do |string|
  click_on(string)
end

Then("I should receive the report file") do
  filename = "#{@organization.slug}"
  page.response_headers['Content-Disposition'].to_s.include?(/filename=\"#{filename}_.*\.zip\"/.to_s)

end

Then("the Report zip file should have documents in it") do
  a = page.driver.response.body.gsub(/[^0-9a-z._]/i, '')
  expect(a).to have_content(".html")
  expect(a).to have_content(".css")
end

Given("the organization enable_workflows option is enabled") do
  @organization.enable_workflows = true
  @organization.save
end

Given("that i am logged in as a supervisor") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given(/^I am on the (\w+) index page for the organization$/) do |controller|
  @controller = controller
  url = "/admin/organization/#{@organization.slug}/#{controller}"
  visit url
end

When(/^I fill in the (\w+) form with:$/) do |record_name, table|
  # table is a Cucumber::Ast::Table
  table.raw.each do |field,value|
    id = "##{record_name}_#{field}"
    e = first(id)
    expect(e).not_to be_nil, "Unable to find #{id}"
    case tag = e.tag_name
    when 'input','textarea'
      e.set(value)
    when 'select'
      option = e.first(:option, value)
      expect(option).not_to be_nil, "Unable to find option #{value}"
      option.select_option
    else
      puts "pending: #{tag}"
      pending # duno how to handle that type of element
    end
  end
end

Then(/^I should be able to see all the (\w+) for the organization$/) do |class_name|
  case class_name
  when /components/
    slugs = Component.where(organization_id: @organization.id).map(&:slug)
  when /workflow/
    slugs = WorkflowStep.where(organization_id: @organization.id).map(&:slug)
  end
  save_page
  slugs.each do |slug|
    expect(page).to have_content(slug)
  end
end

Then("I should see {string}") do |string|
  expect(page).to have_content(string)
end

Given("there is a {string}") do |table|
  create
  pending # Write code here that turns the phrase above into concrete actions
end

Given("the user has a document with a workflow step") do
  wf_start_step = @workflows[1].detect {|wf| wf["start_step"] == true}
  @document = create(:document, organization_id: @organization.id, user_id: @user, workflow_step_id: wf_start_step.id )
  expect(@document.workflow_step_id).to have_content(wf_start_step.id)
end

Given("the user has completed a workflow step") do
  @document.workflow_step_id = WorkflowStep.find(@document.workflow_step_id).next_workflow_step_id
  @document.save
end

When("I go to the document edit page for the users document") do
  visit edit_document_path(:id => @document.edit_id)
end

Then("I should not be able to edit the employee section") do
  puts "##### Cant test beyond this point before we have components and permissions setup #####"
  pending
end

When("I fill in the form with:") do |table|
  # table is a Cucumber::MultilineArgument::DataTable
  pending # Write code here that turns the phrase above into concrete actions
end

When("I click the complete review button") do
  pending # Write code here that turns the phrase above into concrete actions
end
