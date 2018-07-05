Feature: workflow steps supervisor
as a supervisor
In order to do employee review
I want to have a defined set of workflow steps to go thrugh

   Background:
      Given there is a organization
      And the organization enable_workflows option is enabled
      And that I am logged in as a supervisor
      And I am on the admin workflow steps page for organization

   Scenario: create workflow step
      Given I click the create workflow step button
      When I fill in the workflow step form with:
         | slug | step_1 |
         | name | Step 1 |
         | next_step_id | nil|
      And I click create workflow step
      Then I should see "created workflow step"

   Scenario: update workflow step
      Given there are a workflow step
      And I click the edit workflow step button
      When I fill in the workflow step form with:
         | slug | step_54|
         | name | Step 54 |
         | next_step_id | nil |
      And I click create workflow step
      Then I should see "updated workflow step"

   Scenario: delete workflow step
      Given there is a workflow step
      When I click the delete workflow step button
      Then I should see "deleted workflow step"


   Scenario: review employee's document
      Given there is an employee
      And the employee has a document with a workflow step
      And the employee has completed a workflow step
      When I go to the review page for the employee
      Then I should not be able to edit the employee section
      When I fill in the form with:
         | comments | this employee has done good job writing tests for this project |
      And I click the complete review button
      Then I should see "review completed"
