FactoryGirl.define do

  sequence :username do |n|
  	"test#{n}"
  end

  sequence :email do |n|
    "test#{n}@ming.com"
  end

  sequence :weibo do |n|
    "test#{n}"
  end
  
  factory :user do
    username
    email
    weibo
    password 'private'
  end

  factory :room do
    users_id []
  end

  factory :group do
    room
    round_id 0
    betray_penalty 0
    moneys [0, 0, 0]

    after(:create) do |group|
      users = (1..3).map do |e|
        create(:user, group_id: group.id, room_id: group.room_id, round_id: 0)
      end
      group.users_id = users.sort.map {|x| x.id}
      group.save!
      group.room.users_id = group.users_id
      group.room.save!
    end
    status "active"
  end

  # factory :proposal do
	 #  group
	 #  round_id 0
	 #  submitter 1
	 #  acceptor 1
	 #  accepted false
	 #  moneys [1, 2, 3]
	 #  submitter_penalty 0
	 #  acceptor_penalty 0
  # end

end

