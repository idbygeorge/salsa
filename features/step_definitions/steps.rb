
Given("That I am logged in as a super admin") do

  visit "/admin/login"
  user = create(:admin)
  user_assignment = create(:user_assignment, user_id: user.id, role: 'admin')
  fill_in "user_email", :with => user.email
  fill_in "user_password", :with => user.password
  click_button("Log in")
  expect(page).to have_content("Add Organization")
end

Given(/^there is a (\w+) with a (\w+) of "(.*?)"$/) do |class_name, field_name, field_value|
  instance_variable_set("@#{class_name}", create(class_name, field_name => field_value))
end

Given(/^there is a (\w+)$/) do |class_name|
  case class_name
  when /document/ || /canvas_document/
    record = create(class_name, organization_id: @organization.id)
    instance_variable_set("@#{class_name}",record)
  else
    record = create(class_name)
    instance_variable_set("@#{class_name}",record)
  end
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

When(/^I click the SALSA Save link$/) do
  click_on("tb_save")
end

When(/^I click the "(.*?)" link$/) do |string|
  click_link(string)
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

Then(/^I should see "(.*?)" in the url$/) do |string|
  expect(page.current_url).to have_content(string)
end

Then(/^I should be on the (\w+) document page$/) do |string|
  case string
  when /view/
    expect(page.current_url).to have_content(@document.view_id)
  when /edit/
    expect(page.current_url).to have_content(string)
  else
    pending
  end
end

Then(/^I should be on the (\w+) page$/) do |string|
  expect(page.current_url).to have_content(string)
end

Then("I should see {string}") do |string|
  expect(page).to have_content(string)

end

Given(/^I am on the "(.*?)" page$/) do |page|
  visit page
end

Then("I should see a new document edit url") do
  expect(page.current_url).not_to have_content(@document.view_id)
end

Given(/^I am on the (\w*document\b) (\w+) page$/) do |document_type, page_path|
  case document_type
  when /canvas_document/
    FakeWeb.register_uri(:any, "#{@organization.lms_authentication_source}/login/oauth2/auth", :body => "Authorizing", :data => {"access_token":"MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3","refresh_token":"IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk","state":"12345678"})
    debugger
    visit "http://lvh.me:#{Capybara.current_session.port}#{lms_course_document_path(@document.lms_course_id)}"
    # save_page
  when /document/
    visit edit_document_path(@document.edit_id)
  else
    pending
  end
end



Then("I should see a saved document") do
  @document
end
