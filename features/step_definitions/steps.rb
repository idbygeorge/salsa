Given(/^that I am logged in as a (\w+) on the organization$/) do |role|
  visit "/admin/login"
  user = create(role)
  user_assignment = create(:user_assignment, user_id: user.id, role: role, organization_id: @organization.id)
  fill_in "user_email", :with => user.email
  fill_in "user_password", :with => user.password
  click_button("Log in")
  expect(page).to have_content("Logged in successfully")
end

Given(/^that I am logged in as a (\w+)$/) do |role|
  visit "/admin/login"
  user = create(role)
  user_assignment = create(:user_assignment, user_id: user.id, role: role)
  fill_in "user_email", :with => user.email
  fill_in "user_password", :with => user.password
  click_button("Log in")
  expect(page).to have_content("Logged in successfully")
end

Given("there is a workflow_step on the organization") do
  record = create(:workflow_step, organization_id: @organization.id)
  instance_variable_set("@workflow_step",record)
end

Given(/^there is a (\w+)$ with a (\w+) of (\w+)/) do |class_name, field, value|
  record = create(class_name, feild => value)
  instance_variable_set("@#{class_name}",record)
end

Given(/^there is a (\w+)$/) do |class_name|
  record = create(class_name)
  instance_variable_set("@#{class_name}",record)
end

Given("there are documents with document_metas that match the filter") do
  doc = create(:document, organization_id: @organization.id)
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

When("I click the {string} link") do |string|
  click_link(string)
end

When("I click the {string} button") do |string|
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

Given("I am on the workflow steps page for the organization") do
  visit workflow_steps_path(@organization.slug)
  expect(page).to have_content("Workflow Steps")
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

When("I click create workflow step") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I should see {string}") do |string|
  expect(page).to have_content(string)
end

Given("I click the edit workflow step button") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I click the delete workflow step button") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("there is a {string}") do |table|
  create
  pending # Write code here that turns the phrase above into concrete actions
end

Given("the employee has a document with a workflow step") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("the employee has completed a workflow step") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I go to the review page for the employee") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I should not be able to edit the employee section") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I fill in the form with:") do |table|
  # table is a Cucumber::MultilineArgument::DataTable
  pending # Write code here that turns the phrase above into concrete actions
end

When("I click the complete review button") do
  pending # Write code here that turns the phrase above into concrete actions
end
