FactoryGirl.define do
  factory :user do
    email { FFaker::Internet.email }
    password { FFaker::Lorem.words(5).join }
  end
end