FactoryBot.define do
  factory :organization do
    name "example"
    slug "www.example.com"
    default_account_filter '{"account_filter":"FL17"}'
    lms_authentication_source ""
    lms_authentication_key "asdas"
    lms_authentication_id "lkjlk"

  end
end
