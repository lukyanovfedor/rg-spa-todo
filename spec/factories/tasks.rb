FactoryGirl.define do
  factory :task do
    title { Faker::Commerce.product_name }
    project
  end

end
