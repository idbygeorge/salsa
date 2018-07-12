Feature: document
As a teacher from canvas
I want to be able to create a syllabus
in order to define what my class will be doing

  Background:
    Given there is a organization with a lms_authentication_source of "https://instance.instructure.com"

  @mechanize
  @javascript
  Scenario: canvas view document
    Given there is a document
    And I am on the canvas_document view page
    Then I should see "My SALSA"
    And I should see "/lms/courses/" in the url

  Scenario: canvas edit document
  Scenario: canvas template document
  Scenario: canvas relink use existing document
  Scenario: canvas relink template document
  Scenario: canvas relink create new document
