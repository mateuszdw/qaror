FactoryGirl.define do
  factory :user do |fu|
    fu.sequence(:name) { |n| "qaror#{n}" }
    fu.sequence(:email) { |n| "qa#{n}@qaror.com" }
    fu.password "secret"
    fu.status User::STATUS_ACTIVE # status active

    factory :user_not_confirmed do
      status User::STATUS_NOTCONFIRMED # user
    end

    factory :user_with_points do
      after(:create) do |user|
        create(:activity_point, user: user)
      end
    end

    factory :user_with_two_activity_points do
      after(:create) do |user|
        create(:activity_point, user: user)
        create(:activity_point, user: user)
      end
    end

    factory :user_with_zero_points do
      after(:create) do |user|
        create(:activity_point_zero, user: user)
      end
    end

    factory :user_with_undo_points do
      after(:create) do |user|
        create(:activity_point_undo, user: user)
      end
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

  factory :activity do |fa|
    association :user, factory: :user
    activityable_type "Thr"
    fa.sequence(:name) { |n| "activity#{n}" }
    fa.sequence(:ip) { |n| "0.0.0.#{n}" }

    factory :activity_for_answer do
      activityable_type "An"
    end

    factory :activity_for_comment do
      activityable_type "Comment"
    end

    trait :undo do
      undo Activity::UNDO
      undo_at Time.now
    end
  end

  factory :activity_point do |fap|
    association :user, factory: :user
    association :activity, factory: :activity
    value 10
    # fap.sequence(:created_at) { |n| Time.now + 1.minute }

    factory :activity_point_zero do
      value 0
    end

    factory :activity_point_undo do
      undo 1
    end
  end

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
