FactoryGirl.define do
  factory :user do |f|
    f.sequence(:name) { |n| "qaror#{n}" }
    f.sequence(:email) { |n| "qa#{n}@qaror.com" }
    f.password "secret"
    f.status User::STATUS_ACTIVE # status active

    trait :not_confirmed do
      status User::STATUS_NOTCONFIRMED # user
    end

    trait :registered do
      role 1 # user
    end

    trait :with_no_reputation do
      reputation 0
    end

    trait :with_reputation do
      reputation 100
    end

    trait :moderator do
      role 2
    end

    trait :admin do
      role 3
    end
  end

  # factory :activities do
  #   association :user, factory: :user
  #   t.references :activityable, :polymorphic => true
  #   f.sequence(:name) { |n| "activity#{n}" }
  #   f.sequence(:ip) { |n| "0.0.0.#{n}" }
  #   t.datetime :undo_at
  #   t.text :extra
  # end

  factory :thr, aliases: [:question] do
    title "This is long question title"
    content "This is long post content"
    tagnames "tag1 tag2 tag3"
    association :user, factory: :user

    factory :question_with_activity do
      before(:create) do |thr|
        thr.last_activity_user_id = thr.user.id
      end
    end
  end

end
