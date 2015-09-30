FactoryGirl.define do
  factory :project do
    title { Faker::Commerce.product_name }
    user
  end
end
