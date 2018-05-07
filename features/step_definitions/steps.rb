Given("That I am logged in as a super admin") do

  visit "/admin/login"
  user = create(:admin)
  user_assignment = create(:user_assignment, user_id: user.id, role: 'admin')
  fill_in "user_email", :with => user.email
  fill_in "user_password", :with => user.password
  click_button("Log in")
  expect(page).to have_content("Add Organization")
end

Given("there is a organization") do
  @org = create(:organization)
end

Given("there are documents with document_metas that match the filter") do
  doc = create(:document, organization_id: @org.id)
end

Given("the reports are generated") do
    params = {
      "account_filter" => "FL17",
      "controller" => "admin",
      "action" => "canvas"
    }
  report = create(:report_archive, organization_id: @org.id, report_filters: params, generating_at: Time.now)
  ReportHelper.generate_report(@org.slug, "FL17", params, report.id)
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

Then("I should receive the report file") do
  filename = "#{@org.slug}"
  page.response_headers['Content-Disposition'].to_s.include?(/filename=\"#{filename}_.*\.zip\"/.to_s)

end

Then("the Report zip file should have documents in it") do
  a = page.driver.response.body.gsub(/[^0-9a-z._]/i, '')
  expect(a).to have_content(".html")
  expect(a).to have_content(".css")
end
