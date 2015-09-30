FactoryGirl.define do
  factory :comment do
    note { Faker::Lorem.paragraph }
    task
  end
end
