require 'spec_helper'
require 'helper'

describe RoomsController do
	render_views
	before(:each) do
		Pusher.stub(:room_list)
		Pusher.stub(:group_start)
		Pusher.stub(:group_stop)
	end

	describe "GET index" do
		it "returns OK" do	
			get :index, use_route: :RealtimeVote, :format => :json
			expect(response.status).to eq(200)
		end

		it "return a list of rooms" do
			10.times do
				Room.create users_id: []
			end
			rooms = Room.all
			rooms_index = []
			rooms.each do |r|
				rooms_index << {"id" => r.id, "seats" => 3}
			end
			get :index, use_route: :RealtimeVote, :format => :json
			expect(json_rsp).to eq({"rooms" => rooms_index})
		end
	end

	describe "PUT join" do
		it "return error" do
			put :join, use_route: :RealtimeVote
			expect(response.status).to eq(424)
			expect(json_rsp['errors']).to eq('RoomNotFound')
		end

		context "already joined a room" do
			xit 'leaves previous room' do
				
			end

			xit 'destroys previous group' do
				
			end

			xit 'joins new room' do
				
			end
		end

		context "join success" do
			let!(:room) {FactoryGirl.create(:room)}
			let!(:user) {FactoryGirl.create(:user)}

			it 'return valid stauts code' do
				put :join, :room_id => room.id, :user_id => user.id, :format => 'json'
				expect(response.status).to eq(200)
			end

			it 'return valid users' do
				put :join, :room_id => room.id, :user_id => user.id, :format => 'json', use_route: :RealtimeVote
				expect(json_rsp['users']).to eq([user.id])
				expect(json_rsp['group_info']).to eq(nil)
			end

			it 'return valid group' do
				users = create_3_users()
				put :join, :room_id => room.id, :user_id => users[0].id, :format => 'json', use_route: :RealtimeVote
				put :join, :room_id => room.id, :user_id => users[1].id, :format => 'json', use_route: :RealtimeVote
				put :join, :room_id => room.id, :user_id => users[2].id, :format => 'json', use_route: :RealtimeVote
				expect(json_rsp['group_info']).not_to eq(nil)
			end
		end

		context "join fail" do
			it 'return 424' do
				put :join, :format => 'json'
				expect(response.status).to eq(424)
			end
		end
	end

	describe "PUT leave" do
		context "leave success" do			
			context 'leave without a group' do
				let!(:room) {FactoryGirl.create(:room)}
				let!(:user) {FactoryGirl.create(:user)}

				before(:each) do
					Room.join(room.id, user.id)
					put :leave, :room_id => room.id, :user_id => user.id, :format => 'json'
				end

				it 'return 200' do
					expect(response.status).to eq(200)
				end

				it 'return valid user' do
					expect(json_rsp['users']).to eq([])
				end

				it 'return null group' do
					expect(json_rsp['group_id']).to eq(nil)
				end
			end

			context 'leave within a group' do
				let!(:users) {create_3_users}
				let!(:room) {FactoryGirl.create(:room)}
				before(:each) do
					3.times do |i|
						Room.join(room.id, users[i].id)
					end
					put :leave, :room_id => room.id, :user_id => users[0].id, :format => 'json'
				end

				it 'return 200' do
					expect(response.status).to eq(200)
				end

				it 'return valid user' do
					exp_users = users[1..-1].reduce([]) {|m, e| m << e.id}
					expect(json_rsp['users']).to eq(exp_users)
				end

				it 'return a group id' do
					expect(json_rsp['group_id']).not_to eq(nil)
				end
			end
		end	
	end
end