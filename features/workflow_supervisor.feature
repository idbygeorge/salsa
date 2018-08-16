Feature: workflow steps supervisor
as a supervisor
In order to do employee review
I want to have a defined set of workflow steps to go thrugh

  Background:
    Given there is a organization
    And the organization enable_workflows option is enabled
    And that I am logged in as a supervisor on the organization

  Scenario: View all workflow_steps for the organization
    Given there is a workflow
    And there is a workflow_step on the organization
    And I am on the workflow_steps index page for the organization
    Then I should be able to see all the workflow_steps for the organization

  Scenario: create workflow step
     When I click the "New" link
     And I fill in the workflow_step form with:
        | slug | step_1 |
        | name | Step 1 |
        | next_workflow_step_id | |
     And I click on "Create Workflow step"
     Then I should see "Workflow step was successfully created."

  Scenario: update workflow step
     Given there is a workflow_step on the organization
     And I am on the workflow_steps index page for the organization
    When I click the "Edit" link
     When I fill in the workflow_step form with:
        | slug | step_54|
        | name | Step 54 |
        | next_workflow_step_id | |
     And I click on "Update Workflow step"
     Then I should see "Workflow step was successfully updated."

  Scenario: delete workflow step
     Given there is a workflow_step on the organization
     And I am on the workflow_steps index page for the organization
     When I click the "Delete" link
     Then I should see "Workflow step was successfully destroyed."

  @javascript
  Scenario: complete step_4
    Given there is a workflow
    And there is a document on the fourth step in the workflow and assigned to the current user
    And I am on the "/workflow/documents" page
    When I click the "#edit_document" link
    # TODO add javascript tag so we can save the document
    And I click the "#tb_share" link
    Then the document should be on step_5

  @javascript
  Scenario: fail to complete step_1
    Given there is a workflow
    And there is a user with the role of staff
    And there is a document on the first step in the workflow and assigned to the user
    And I am on the "/workflow/documents" page
    Then I should not see "Edit"

  @javascript
  Scenario: fail to complete final_step
    Given there is a workflow
    And there is a document on the last step in the workflow and assigned to the current user
    And I am on the "/workflow/documents" page
    Then I should not see "Edit"
