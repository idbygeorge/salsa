Feature: Download report
as a customer
In order to view my docs
I want to be able to download a report


  Scenario: download report

    Given there is a organization
    And That I am logged in as a super admin
    And there are documents with document_metas that match the filter
    And the reports are generated
    And I am on the admin reports page for organization

    When I click the "Download Report" link
    Then I should receive the report file
    And the Report zip file should have documents in it
