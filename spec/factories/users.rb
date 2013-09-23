# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:username) {|n| "u#{n}"}
    password 'private'
    password_confirmation 'private'
    round_id 0
  end
end
