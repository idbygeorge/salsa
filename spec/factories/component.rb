FactoryBot.define do
  factory :component do
    name {Faker::Name.unique.name}
    slug {Faker::Types.unique.rb_string}
    description {Faker::StarWars.quote}
    organization_id {Faker::Number.number(3)}
    category {"document"}
    layout {"<head></head>"}
    format {"html"}
  end
end
