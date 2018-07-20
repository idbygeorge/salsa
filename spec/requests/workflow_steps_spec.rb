require 'rails_helper'

RSpec.describe "WorkflowSteps", type: :request do
  describe "GET /workflow_steps" do
    it "works! (now write some real specs)" do
      get workflow_steps_path
      expect(response).to have_http_status(200)
    end
  end
end
