require 'faker'

FactoryBot.define do
  factory :workflow_step do
    name Faker::Name.unique.name
    slug Faker::Types.unique.rb_string
    start_step false
    end_step false
    organization_id 1
    after :create do |workflow_step|
      component = create :component, slug: workflow_step.slug, role: "staff", role_organization_level: 0, organization_id: workflow_step.organization_id
      workflow_step.component_id = component.id
      workflow_step.save
    end
  end
end
