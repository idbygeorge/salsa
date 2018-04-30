FactoryBot.define do
  factory :user_admin do
    name: "gloadmin"
    email: "gloadmin@localhost"
    password: "password"

    factory :user_assignments do
      role: "admin"
      cascades: true

      user_admin
    end
  end
end
