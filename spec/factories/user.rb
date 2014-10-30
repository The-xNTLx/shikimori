FactoryGirl.define do
  factory :user do
    sequence(:nickname) { |n| "user_#{n}" }
    email { FactoryGirl.generate(:email) }
    password "123"
    last_online_at DateTime.now

    notifications User::DEFAULT_NOTIFICATIONS

    trait :preferences do
      after :create do |user|
        FactoryGirl.create :user_preferences, user: user
      end
    end

    trait :admin do
      id User::Admins.first
    end

    trait :contests_moderator do
      id User::ContestsModerators.first
    end

    trait :without_password do
      password nil

      after :build do |user|
        user.stub(:password_required?).and_return false
      end
    end
  end
end
