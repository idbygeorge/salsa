FactoryBot.define do
  factory :organization do
    name "example"
    slug "localhost"
    default_account_filter '{"account_filter":"FL17"}'
    lms_authentication_source ""
    lms_authentication_key Faker::Number.number(20)
    lms_authentication_id Faker::Number.number(10)
  end
end
