Feature: components admin
as a admin
In order to have a template for SALSA's
I want to create, edit and view components

  Background:
    Given there is a organization
    And that I am logged in as a admin on the organization
    And I am on the components index page for the organization

  Scenario: View all components for the organization
    Given there are 5 components for the organization
    And I am on the components index page for the organization
    Then I should be able to see all the components for the organization

  Scenario: create component
     When I click the "Add Component" link
     And I fill in the component form with:
        | name | Step 1 |
        | slug | step_1 |
        | description | this is a description |
        | category | document |
        | layout | <head></head> |
        | format | html |
     And I click on "Create Component"
     Then I should see "Component was successfully created."

  Scenario: update component
     Given there is a component on the organization
     And I am on the components index page for the organization
     And I click the "Edit" link
     When I fill in the component form with:
        | name | Step not 1 |
        | slug | step_34 |
        | description | this is a different description |
        | category | document |
        | layout | <head></head><body></body> |
        | format | html |
     And I click on "Update Component"
     Then I should see "Component was successfully updated."
