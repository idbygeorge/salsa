require "rails_helper"

RSpec.describe WorkflowStepsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/workflow_steps").to route_to("workflow_steps#index")
    end

    it "routes to #new" do
      expect(:get => "/workflow_steps/new").to route_to("workflow_steps#new")
    end

    it "routes to #show" do
      expect(:get => "/workflow_steps/1").to route_to("workflow_steps#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/workflow_steps/1/edit").to route_to("workflow_steps#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/workflow_steps").to route_to("workflow_steps#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/workflow_steps/1").to route_to("workflow_steps#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/workflow_steps/1").to route_to("workflow_steps#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/workflow_steps/1").to route_to("workflow_steps#destroy", :id => "1")
    end

  end
end
