require 'spec_helper'

describe Room do
  before(:each) do
    Pusher.stub(:join)
    Pusher.stub(:leave)
    Pusher.stub(:start)

    # FactoryGirl.generate :user
    create(:user)
    3.times do |x|
      # user = FactoryGirl.create(:user)
      # user = User.create(username: "#{x}", password: '123', 
      #                    total_earning: 0)
    end

  end

  describe '.join_room' do
    context 'when seat is available' do
      FactoryGirl.create(:user)
    end
  end

  describe '.leave_room' do
    
  end
  
end