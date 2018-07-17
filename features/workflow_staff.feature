Feature: workflow staff
As a staff member
in order to complete my yearly review
I want to complete a workflow step

  Background:
    Given there is a organization
    And the organization enable_workflows option is enabled
    And there is a workflow

  Scenario: complete step 1
    Given that I am logged in as a staff on the organization
    And there is a document on the first step in the workflow and assigned to the user
    And I am on the "/workflow/documents" page
    Then I click the "Edit" link
    # TODO add javascript tag so we can save the document
    And I click the "tb_share" link
    Then the document should be on step_2

  Scenario: complete last step
    Given that I am logged in as a staff on the organization
    And there is a document on the last step in the workflow and assigned to the user
    And I am on the "/workflow/documents" page
    When I click the "Edit" link
    # TODO add javascript tag so we can save the document
    And I click the "tb_share" link
    Then the document should be on step_2
