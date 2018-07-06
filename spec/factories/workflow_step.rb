
FactoryBot.define do
  factory :workflow_step do
    name "Step 1"
    slug "step_1"
    start_step true
    organization_id 1
  end
end
