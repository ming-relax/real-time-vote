require 'spec_helper'
require 'helper'

describe Room do
  describe '.add_user' do
    it 'add success' do
      u = create(:user)
      room = create(:room)
      Room.add_user(room.id, u.id)
      room = Room.find(room.id)
      expect(room.users_id).to eq([u.id])
    end

    it 'add success' do
      u = create(:user)
      room = create(:room)
      expect(Room.add_user(room.id, u.id)).to eq([u.id])
    end

    it 'add fail when cannot find room ' do |variable|
      u = create(:user)
      expect{Room.add_user(1, u.id)}.to raise_error(RoomError, 'RoomNotFound')      
    end

    it 'add fail when room is full' do

      room = create(:room)
      3.times do |n|
        u = create(:user, username: generate(:username))
        Room.add_user(room.id, u.id)
      end
      
      u = create(:user, username: generate(:username))
      expect{Room.add_user(room.id, u.id)}.to raise_error(RoomError, 'RoomFull')
    end
  end

  describe '.delete_user' do
    it 'delete success' do
      u = create(:user)
      room = create(:room)
      Room.add_user(room.id, u.id)
      Room.delete_user(room.id, u.id)
      room = Room.find(room.id)
      expect(room.users_id).to eq([])
    end

    it 'delete failed when room not found' do
      u = create(:user)
      expect{Room.delete_user(1, u.id)}.to raise_error(RoomError, 'RoomNotFound')
    end

    it 'delete failed when room is empty' do
      u = create(:user)
      room = create(:room)
      expect{Room.delete_user(room.id, u.id)}.to raise_error(RoomError, 'RoomEmpty')
    end

    it 'delete fail when delte a non user' do
      u = create(:user)
      room = create(:room)
      Room.add_user(room.id, u.id)
      expect{Room.delete_user(room.id, 100)}.to raise_error(RoomError, 'RoomNullUser')
    end
  end

  describe '.join' do

    it "set room_id when join success" do
      user = FactoryGirl.create(:user)
      room = FactoryGirl.create(:room)
      Room.join(room.id, user.id)

      user.reload
      room.reload
      expect(user.room_id).to eq(room.id)
      expect(room.users_id).to eq([user.id])
    end

    context 'when already in a room' do
      let(:user) {FactoryGirl.create(:user)}
      let(:room) {FactoryGirl.create(:room)}

      it 'leaves previous room' do
        Room.join(room.id, user.id)
        room_2 = FactoryGirl.create(:room)

        Room.join(room_2.id, user.id)
        r = Room.find(room.id)
        expect(r.users_id).to eq([])
      end
    end

    context 'when join success' do

      let(:users) {create_3_users}
      let(:room) {FactoryGirl.create(:room)}

      it 'return valid info' do
        users_ret, group_info = Room.join(room.id, users[0].id)
        expect(users_ret).to eq([users[0].id])
        expect(group_info).to be_nil  
      end

      it 'change room' do
        Room.join(room.id, users[0].id)
        r = Room.find(room.id)
        expect(r.users_id).to eq([users[0].id])
      end

      context 'when room is full' do
        before(:each) do
          2.times do |i|
            Room.join(room.id, users[i].id)
          end  
        end

        before(:each) do
          Group.stub(:generate_penalty).with().and_return(20)
        end
        
        it 'return group info' do
          users_ret, group_info = Room.join(room.id, users[2].id)
          expect(users_ret).to eq(users.map {|u| u.id})
        end

        it 'create group' do 
          expect{Room.join(room.id, users[2].id)}.to change{Group.count}.from(0).to(1)
        end

        it 'init group info' do
          Room.join(room.id, users[2].id)
          u = User.find(users[0].id)
          expect(u.group.status).to eq('active')
          expect(u.group.moneys).to eq([0, 0, 0])
          expect(u.group.users_id).to eq(users.map {|u| u.id})
          expect(u.group.betray_penalty).to eq(20)
          expect(u.group.acked_users).to be_nil
        end

      end
      
      
    end
  end

  describe '.leave' do
    context 'when room is not full' do
      let(:users) { create_3_users }
      let(:room) { create(:room) }

      before(:each) do
        2.times do |i|
          Room.join(room.id, users[i].id)
        end  
      end

      it 'change room' do
        Room.leave(room.id, users[0].id)
        r = Room.find(room.id)
        expect(r.users_id).to eq([users[1].id])
      end

      it 'change user' do
        Room.leave(room.id, users[0].id)
        u = User.find(users[0].id)
        expect(u.room_id).to be_nil
      end

      it 'return valid' do
        expect(Room.leave(room.id, users[0].id)).to eq([[users[1].id], nil])
      end
    end

    context 'when room is full' do
      let(:users) {create_3_users}
      let(:room) {create(:room)}

      before(:each) do
        3.times do |i|
          Room.join(room.id, users[i].id)
        end
      end

      it "change user.group_id status" do
        Room.leave(room.id, users[0].id)
        u = User.find(users[0].id)
        expect(u.group_id).to be_nil
      end

      it 'change group status' do
        Room.leave(room.id, users[0].id)
        u = User.find(users[1].id)
        expect(u.group.status).to eq('destroyed')
      end

      it 'return valid' do
        group_id = User.find(users[0].id).group_id
        expect(Room.leave(room.id, users[0].id)).to eq([[users[1].id, users[2].id], group_id])
      end
    end
  end
  
end