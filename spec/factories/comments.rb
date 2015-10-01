FactoryGirl.define do
  factory :comment do
    note { Faker::Lorem.paragraph }
    task

    after(:build) do |c|
      c.attachments << FactoryGirl.create(:attachment)
    end
  end
end
