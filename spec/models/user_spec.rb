require 'spec_helper'

describe User do
  describe ".query_user" do
    context "when group is not made" do
      it "returns only user info" do
        user = FactoryGirl.create(:user)
        expected_info = {
          "myself" => {
            "id" => user.id,
            "room_id" => nil,
            "total_earning" => 0
          }
        }
        expect(User.query_user(user.id)).to eq(expected_info)
      end
    end

    context "when group is made" do
      context "when no deal is made" do
        
        let(:group) { FactoryGirl.create(:group) }
        let(:users) { group.users }

        context "when no proposal is made" do
          it "retuns group info" do
            user = group.users[0]
            expected_info = {
              "myself" => {
                "id" => user.id,
                "room_id" => user.room_id,
                "total_earning" => user.total_earning
              },
              "group" => {
                "id" => group.id,
                "room_id" => group.room_id,
                "round_id" => group.round_id,
                "betray_penalty" => group.betray_penalty,
                "moneys" => [0, 0, 0],
                "users" => users.map { |u| JSON.parse(u.to_json(:only => [:id, :username, :total_earning])) },
                "status" => "active",
                "acked_users" => nil
              },
              "opponents" => [
                { 
                  "username" => group.users[1].username,
                  "id" => group.users[1].id,
                  "proposal_to_me" => nil
                },
                {
                  "username" => group.users[2].username,
                  "id" => group.users[2].id,
                  "proposal_to_me" => nil
                }    
              ]
            }
            expect(User.query_user(user.id)).to eq(expected_info)
          end  
        end

        context "when only one proposal" do
          it "returns one proposal" do
            me = group.users[0]
            submitter = group.users[1]
            moneys = [10, 20, 70]
            proposal = Proposal.submit(group_id: group.id,
              round_id: group.round_id,
              submitter: submitter.id,
              acceptor: me.id,
              moneys: moneys)

            expected_info = {
              "myself" => {
                "id" => me.id,
                "room_id" => me.room_id,
                "total_earning" => 0
              },
              "group" => {
                "id" => group.id,
                "room_id" => group.room_id,
                "round_id" => group.round_id,
                "betray_penalty" => group.betray_penalty,
                "moneys" => [0, 0, 0],
                "users" => users.map { |u| JSON.parse(u.to_json(:only => [:id, :username, :total_earning])) },
                "status" => "active",
                "acked_users" => nil
              },
              "opponents" => [
                { 
                  "username" => group.users[1].username,
                  "id" => group.users[1].id,
                  "proposal_to_me" => proposal
                },
                {
                  "username" => group.users[2].username,
                  "id" => group.users[2].id,
                  "proposal_to_me" => nil
                }    
              ]             
            }
            result = User.query_user(me.id, group.id, group.round_id)
            expect(result['opponents']).to eq(expected_info['opponents'])
          end
        end
        
        context "when two proposals are made" do
          it "returns two proposals" do
            me = group.users[0]
            submitter1 = group.users[1]
            submitter2 = group.users[2]
            moneys = [10, 20, 70]

            proposal2 = Proposal.submit(group_id: group.id,
              round_id: group.round_id,
              submitter: submitter2.id,
              acceptor: me.id,
              moneys: moneys)

            proposal1 = Proposal.submit(group_id: group.id,
              round_id: group.round_id,
              submitter: submitter1.id,
              acceptor: me.id,
              moneys: moneys)

            expected_info = {
              "myself" => {
                "id" => me.id,
                "room_id" => me.room_id,
                "total_earning" => 0
              },
              "group" => {
                "id" => group.id,
                "room_id" => group.room_id,
                "round_id" => group.round_id,
                "betray_penalty" => group.betray_penalty,
                "moneys" => [0, 0, 0],
                "users" => users.map { |u| JSON.parse(u.to_json(:only => [:id, :username, :total_earning])) },
                "status" => "active",
                "acked_users" => nil,
              },
              "opponents" => [
                { 
                  "username" => group.users[1].username,
                  "id" => group.users[1].id,
                  "proposal_to_me" => proposal1
                },
                {
                  "username" => group.users[2].username,
                  "id" => group.users[2].id,
                  "proposal_to_me" => proposal2
                }    
              ]                           
            }
            result = User.query_user(me.id, group.id, group.round_id)
            expect(result['opponents']).to eq(expected_info['opponents'])            
          end
        end
        
        context "when multiple proposals are made" do
          it "returns two proposals" do
            me = group.users[0]
            submitter1 = group.users[1]
            submitter2 = group.users[2]
            proposal1 = Proposal.submit(group_id: group.id,
              round_id: group.round_id,
              submitter: submitter1.id,
              acceptor: me.id,
              moneys: [10, 20, 70])

            proposal2 = Proposal.submit(group_id: group.id,
              round_id: group.round_id,
              submitter: submitter2.id,
              acceptor: me.id,
              moneys: [1, 1, 98])

            proposal3 = Proposal.submit(group_id: group.id,
              round_id: group.round_id,
              submitter: submitter2.id,
              acceptor: me.id,
              moneys: [1, 0, 99])

            proposal4 = Proposal.submit(group_id: group.id,
              round_id: group.round_id,
              submitter: submitter1.id,
              acceptor: me.id,
              moneys: [2, 2, 96])


            expected_info = {
              "myself" => {
                "id" => me.id,
                "room_id" => me.room_id,
                "total_earning" => 0
              },
              "group" => {
                "id" => group.id,
                "room_id" => group.room_id,
                "round_id" => group.round_id,
                "betray_penalty" => group.betray_penalty,
                "moneys" => [0, 0, 0],
                "users" => users.map { |u| JSON.parse(u.to_json(:only => [:id, :username, :total_earning])) },
                "status" => "active",
                "acked_users" => nil,
              },
              "opponents" => [
                { 
                  "username" => group.users[1].username,
                  "id" => group.users[1].id,
                  "proposal_to_me" => proposal4.moneys
                },
                {
                  "username" => group.users[2].username,
                  "id" => group.users[2].id,
                  "proposal_to_me" => proposal3.moneys
                }    
              ]             


            }
            expect(User.query_user(me.id)).to eq(expected_info)            
            
          end
        end

      end

      context "when deal is made" do
        let(:group) { FactoryGirl.create(:group) }
        let(:users) { group.users }

        it "returns the deal" do
          me = group.users[0]
          submitter1 = group.users[1]
          submitter2 = group.users[2]
          moneys = [10, 20, 70]
          proposal1 = Proposal.submit(group_id: group.id,
            round_id: group.round_id,
            submitter: submitter1.id,
            acceptor: me.id,
            moneys: moneys)

          proposal2 = Proposal.submit(group_id: group.id,
            round_id: group.round_id,
            submitter: submitter2.id,
            acceptor: me.id,
            moneys: moneys)
          
          Proposal.accept(id: proposal1.id, group_id: group.id)
          expected_info = {
            "myself" => {
              "id" => me.id,
              "room_id" => me.room_id,
              "total_earning" => 10
            },
            "group" => {
              "id" => group.id,
              "room_id" => group.room_id,
              "round_id" => group.round_id,
              "betray_penalty" => group.betray_penalty,
              "moneys" => moneys,
              "users" => users.map { |u| u.reload; JSON.parse(u.to_json(:only => [:id, :username, :total_earning])) },
              "status" => "deal",
              "acked_users" => nil,
              "deal" => proposal1
            },
            "opponents" => [
              { 
                "username" => group.users[1].username,
                "id" => group.users[1].id,
                "proposal_to_me" => proposal1.moneys
              },
              {
                "username" => group.users[2].username,
                "id" => group.users[2].id,
                "proposal_to_me" => proposal2.moneys
              }    
            ]             

          }
          expect(User.query_user(me.id)).to eq(expected_info)

        end
      end
    end
  end
end
