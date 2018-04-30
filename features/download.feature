Feature: Download report
as a customer
In order to view my docs
I want to be able to download a report


  Scenario: download report

    Given That I am logged in as a super admin 
    And there is a organization
    And there are documents with documnet metas that match the filter
    And I am authorized on the organization
    And the reports need to be generated
    And I am on the admin reports page for organization


    When I click "Download Report #"
    Then the report should download
    And the Report zip file should have documents in it
