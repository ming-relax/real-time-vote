describe Room do
  before(:each) do
    3.times do |x|
      # user = FactoryGirl.create(:user)
      user = User.create(username: "#{x}", password: '123', 
                         total_earning: 0)
    end

  end

  after(:each) do
    40.times do |i|
      $redis.set("rooms:#{i}", {:users => []}.to_json)
    end
  end

  it 'add_user' do
    err, users = Room.add_user(2, 1, "1")
    err.should be_nil
  end


end