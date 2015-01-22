require 'spec_helper'

describe Proposal do


  describe '.submit' do

    before(:each) do
      @group = FactoryGirl.create(:group)
      @users = (0..2).map do |i|
        User.find(@group.users_id[i])
      end
      @users_id = @users.map {|u| u.id.to_s }
    end

    context 'when deal was not made' do
      it 'add a record to db' do
        @group.update(status: 'active')
        expect {
          Proposal.submit(group_id: @group.id,
            round_id: @group.round_id,
            submitter: @users[0].id,
            acceptor: @users[1].id,
            moneys: {@users_id[0] => 10, @users_id[1] => 20, @users_id[2] => 70})
        }.to change { Proposal.count }.by(1)
      end
    end

    context 'when deal was made' do
      it 'raise exception' do
        @group.update_attribute(:status, "deal")
        expect {
          Proposal.submit(group_id: @group.id,
            round_id: @group.round_id,
            submitter: @users[0].id,
            acceptor: @users[1].id,
            moneys: {@users_id[0] => 10, @users_id[1] => 20, @users_id[2] => 30})
        }.to raise_error
      end
    end
  end

  describe '.accept' do  

    before(:each) do
      @group = FactoryGirl.create(:group, betray_penalty: 20)
      @users = (0..2).map do |i|
        User.find(@group.users_id[i])
      end
      @users_id = @users.map {|u| u.id.to_s}
      @proposal = Proposal.submit(group_id: @group.id,
                                  round_id: @group.round_id,
                                  submitter: @users[0].id,
                                  acceptor: @users[1].id,
                                  moneys: {@users_id[0] => 10, @users_id[1] => 20, @users_id[2] =>70})

    end
    
    context 'when deal was made' do
      it "raise exception when accept" do
        @group.update(status: "deal")
        expect {
          Proposal.accept(id: @proposal.id, group_id: @group.id)
        }.to raise_error
      end

      it "raise exception when submit" do
        @group.update(status: "deal")
        expect {
          Proposal.submit(group_id: @group.id,
                                  round_id: @group.round_id,
                                  submitter: @users[0].id,
                                  acceptor: @users[1].id,
                                  moneys: {@users_id[0] => 10, @users_id[1] => 20, @users_id[2] =>70})
        }.to raise_error
      end
    end

    context 'when deal was not made' do
      context "simple accept" do
        before(:each) do
          @deal, @new_moneys = Proposal.accept(id: @proposal.id, group_id: @group.id)
        end

        it 'return deal and new_moneys' do
          expect(@deal.moneys).to eq({@users_id[0] => 10, @users_id[1] => 20, @users_id[2] =>70})
          expect(@new_moneys).to eq({@users_id[0] => 10, @users_id[1] => 20, @users_id[2] =>70})
        end

        it 'change group status to deal' do
          expect(Group.find(@group.id).status).to eq('deal')
        end

        it "update group earning" do
          expect(Group.find(@group.id).moneys).to eq({@users_id[0] => 10, @users_id[1] => 20, @users_id[2] =>70})
        end

        it "dont update group's round" do
          expect(Group.find(@group.id).round_id).to eq(0)
        end

        it "update user's earning" do
          expect(User.find(@users[0].id).total_earning).to eq(10)
          expect(User.find(@users[1].id).total_earning).to eq(20)
          expect(User.find(@users[2].id).total_earning).to eq(70)
        end

        it "change proposal to accepted" do
          expect(Proposal.find(@proposal.id).accepted).to be_true
        end  
      end

      context 'when betray happens' do
        before(:each) do

          Proposal.accept(id: @proposal.id, group_id: @group.id)

          @group = Group.update(@group.id, status: "active", round_id: @group.round_id + 1)

        end

        it "update proposal's betray penalty when submitter change" do
          group = Group.find(@group.id)
          expect(group.moneys).to eq({@users_id[0] => 10, @users_id[1] => 20, @users_id[2] => 70})

          # submitter: users-2; acceptor: users-1
          # 10 20 70; betray: 20
          # 0  -20 0 --> 10 0 70 + 30 50 20 --> 40 50 90
          second_proposal = Proposal.submit(group_id: @group.id,
                                  round_id: @group.round_id,
                                  submitter: @users[2].id,
                                  acceptor: @users[1].id,
                                  moneys: {@users_id[0] => 30, @users_id[1] => 50, @users_id[2] => 20})


          deal, new_moneys = Proposal.accept(id: second_proposal.id, group_id: @group.id)
          expect(deal.moneys).to eq({@users_id[0] => 30, @users_id[1] => 30, @users_id[2] => 20})
          expect(new_moneys).to eq({@users_id[0] => 40, @users_id[1] => 50, @users_id[2] => 90})
          expect(User.find(@users[0].id).total_earning).to eq(40)
          expect(User.find(@users[1].id).total_earning).to eq(50)
          expect(User.find(@users[2].id).total_earning).to eq(90)

          group = Group.find group.id
          expect(group.status).to eq("deal")
          expect(group.moneys).to eq({@users_id[0] => 40, @users_id[1] => 50, @users_id[2] => 90})
        end

        it "update propsoal's betray penaly when acceptor change" do
          # submitter: users-0; acceptor: users-2
          # 10 20 70; betray: 20
          # -20 0 0 --> -10 20 70 + 30 50 20 --> 20 70 90
          second_proposal = Proposal.submit(group_id: @group.id,
                                  round_id: @group.round_id,
                                  submitter: @users[0].id,
                                  acceptor: @users[2].id,
                                  moneys: {@users_id[0] => 30, @users_id[1] => 50, @users_id[2] => 20})

          deal, new_moneys = Proposal.accept(id: second_proposal.id, group_id: @group.id)  
          group = Group.find(@group.id)
          expect(group.moneys).to eq({@users_id[0] => 20, @users_id[1] => 70, @users_id[2] => 90})
          expect(User.find(@users[0].id).total_earning).to eq(20)
          expect(User.find(@users[1].id).total_earning).to eq(70)
          expect(User.find(@users[2].id).total_earning).to eq(90)
          expect(deal.moneys.values).to eq([10, 50, 20])
          expect(new_moneys.values).to eq([20, 70, 90])
      
        end
      end

    end
  end

  describe ".deal" do
    it "raises error when group is nil"
    it "raises error when group status is not deal"    
    it "raises error when the proposal is not accepted"
    it "raises error when deal is nil"
    it "returns right deal"
  end

  describe ".to_me" do
    before(:each) do
      @group = FactoryGirl.create(:group)
      @users = @group.users
      @users_id = @users.map {|u| u.id.to_s}
    end

    it "raises error when group is nil"
    it "raises error when no proposal"
    it "raises error when deal is made"

    context "when no proposal submitted" do
      it "returns [nil, nil] to me" do
        proposals = Proposal.to_me(@group, @users[0].id)
        expect(proposals).to eq([nil, nil])
      end
    end

    context "when only one proposal" do
      it "returns right proposals to me" do
        p = Proposal.submit(
          group_id: @group.id,
          round_id: @group.round_id,
          submitter: @users[0].id,
          acceptor: @users[2].id,
          moneys: {@users_id[0] => 10, @users_id[1] => 20, @users_id[2] => 70}
        )
        proposals = Proposal.to_me(@group, @users[2].id)
        expect(proposals).to eq([p, nil])
      end      
    end

    context "when two proposals submitted" do
      it "returns right proposal to me" do
        p1 = Proposal.submit(
          group_id: @group.id,
          round_id: @group.round_id,
          submitter: @users[0].id,
          acceptor: @users[2].id,
          moneys: {@users_id[0] => 10, @users_id[1] => 20, @users_id[2] => 70}
        )

        p2 = Proposal.submit(
          group_id: @group.id,
          round_id: @group.round_id,
          submitter: @users[1].id,
          acceptor: @users[2].id,
          moneys: {@users_id[0] => 10, @users_id[1] => 10, @users_id[2] => 80}
        )

        proposals = Proposal.to_me(@group, @users[2].id)
        expect(proposals).to eq([p1, p2])
      end
    end

    context "when three proposals submitted" do
      it "returns 2 proposals" do
        p1 = Proposal.submit(
          group_id: @group.id,
          round_id: @group.round_id,
          submitter: @users[0].id,
          acceptor: @users[2].id,
          moneys: {@users_id[0] => 10, @users_id[1] => 20, @users_id[2] => 70}
        )

        p2 = Proposal.submit(
          group_id: @group.id,
          round_id: @group.round_id,
          submitter: @users[1].id,
          acceptor: @users[2].id,
          moneys: {@users_id[0] => 0, @users_id[1] => 20, @users_id[2] => 80}
        )
        p3 = Proposal.submit(
          group_id: @group.id,
          round_id: @group.round_id,
          submitter: @users[1].id,
          acceptor: @users[2].id,
          moneys: {@users_id[0] => 10, @users_id[1] => 40, @users_id[2] => 50}
        )
        proposals = Proposal.to_me(@group, @users[2].id)
        expect(proposals).to eq([p1, p3])
      end
    end
  end 

end
