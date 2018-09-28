# How to setup workflows for a Organization

## Create/Edit Organization
  when editing or creating the organization
  check the `enable workflows` checkbox
  and if desired check the `enable workflow report` checkbox

## Create/Edit Sub Organization(s)
  when editing or creating the organization
  check the `enable workflows` checkbox,
  check the `enable workflow report` checkbox if desired,
  check the `enable workflows from parents` checkbox if desired,
  and check the `track_meta_info_from_document` checkbox if desired

## Create/Edit Workflow_steps
  go to the workflow steps page on the top level organization
  then create the desired workflow from the last step example below

  | Name     | Slug   | Next Workflow Step | step_type    |
  |------    |------  |--------------------|-----------   |
  | Archived | step_5 | nil                | end_step     |
  | Step 4   | step_4 | step_5             | default_step |
  | Step 3   | step_3 | step_4             | default_step |
  | Step 2   | step_2 | step_3             | default_step |
  | Step 1   | step_1 | step_2             | start_step   |

  After creating the workflow steps you need to go back and edit and click add step email for each step besides the last step
  the mail component needs to have the layout set to liquid and the category set to mailer

## Edit Components
  components should have been created with the slug matching your workflow steps
  go and edit these components to match what you want each step to look like and assign a role to each component depending on who should be able to access each step and set the format to html

  | Role    | Slug   | Next Workflow Step | step_type    |
  |------    |------  |--------------------|-----------   |
  | Archived | step_5 | nil                | end_step     |

## Add Period(s)
  go to the manage periods page for the organization then add a period for each period you want to start a workflow in

## Import Users
  go to the import users page for the organization you want to import users to
  then add emails seperated by a newline or comma select an organization and click save users

## Start Workflows
  go to the start workflow page for the organization then type a document name for the period and select a starting_workflow_step and a period then click start workflow for period
