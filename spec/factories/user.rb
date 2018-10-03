FactoryBot.define do
  factory :user, class: User do
    name {Faker::Name.name}
    email {Faker::Internet.email}
    password { "password" }
    created_at {Time.now.ago(10)}
  end
  factory :user_assignment do
    role {'admin'}
    cascades {true}
  end
end
