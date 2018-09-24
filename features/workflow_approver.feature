Feature: workflow approver
As a approver
in order to approve my employees documents
I want to complete a workflow step

  Background:
    Given there is a organization with a sub organization
    And the organization enable_workflows option is enabled
    And there is a workflow
    And there is a user with the role of staff on the sub organization

  @javascript
  Scenario: complete step 4
    Given that I am logged in as a approver on the organization
    And there is a document on the fourth step in the workflow and assigned to the user on the sub org
    And I am on the "/workflow/documents" page
    Then I click the "#edit_document" link
    And I click the "#tb_share" link
    Then the document should be on step_5

  @javascript
  Scenario: fail to edit step 2
    Given that I am logged in as a approver on the organization
    And there is a document on the second step in the workflow and assigned to the user
    And I am on the "/workflow/documents" page
    Then I should not see "Edit"

  @javascript
  Scenario: fail to edit final_step
    Given that I am logged in as a approver on the organization
    And there is a document on the last step in the workflow and assigned to the user
    And I am on the "/workflow/documents" page
    Then I should not see "Edit"
