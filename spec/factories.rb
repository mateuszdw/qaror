FactoryGirl.define do
  factory :user do |f|
    f.sequence(:name) { |n| "qaror#{n}" }
    f.sequence(:email) { |n| "qa#{n}@qaror.com" }
    f.password "secret"
    f.status 2
  end
end
