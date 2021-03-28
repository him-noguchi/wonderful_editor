FactoryBot.define do
  factory :user do
    name { Faker::Name.name[0..30] }
    password { Faker::Internet.password }
    sequence(:email) {|n| "#{n}_#{Faker::Internet.email}" }
  end
end
