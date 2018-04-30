Given("That I am logged in as a super admin") do
  visit "http://localhost:3000/admin/login"
  save_and_open_page
  user = create(:user_admin)
  fill_in "user_email", :with => user.name
  fill_in "user_password", :with => user.password
  click_button("Log in")
  expect(page).to have_content("Salsa Admin")
end

Given("there is a organization") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("there are documents with documnet metas that match the filter") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("I am authorized on the organization") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("the reports need to be generated") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("I am on the admin reports page for organization") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I click {string}") do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the report should download") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the Report zip file should have documents in it") do
  pending # Write code here that turns the phrase above into concrete actions
end
