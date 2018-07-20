json.extract! workflow_step, :id, :slug, :created_at, :updated_at
json.url workflow_step_url(workflow_step, format: :json)
