FactoryGirl.define do
  factory :post do
    title { FFaker::Lorem.words(5).join(" ") }
    content { FFaker::Lorem.paragraph }
  end
end