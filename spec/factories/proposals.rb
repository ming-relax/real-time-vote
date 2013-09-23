# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :proposal do
    group_id 1
    round_id 1
    submitter 1
    acceptor 1
    accepted false
    moneys [1, 2, 3]
    submitter_penalty 0
    acceptor_penalty 0
  end
end
