require 'spec_helper'

def form_a_group
  users = []
    # group = FactoryGirl.create(:group)
    group = Group.create(room_id: 0, 
                         round_id: 1,
                         betray_penalty: 20,
                         moneys: [0, 0, 0])
    3.times do |x|
      # user = FactoryGirl.create(:user)
      user = User.create(username: "#{x}", password: '123', 
                         group_id: group.id, room_id: group.room_id,
                         total_earning: 0)
    end
  [users, group]
end


describe Proposal do
  it {should_not be_valid}

  it 'should be a valid proposal' do
    p = create(:proposal)
    p.should be_valid

    p = create(:proposal, accepted: true)
    p.should be_valid

    p = create(:proposal, accepted: false)
    p.should be_valid

  end

  it 'current round is not over' do
    p = create(:proposal, accepted: false)
    Proposal.current_round_is_over?(p.round_id, p.group_id).should be_false

  end

  it 'accepted_proposal ok ' do
    p = create(:proposal, accepted: false, round_id: 0)
    users, group = form_a_group
    Proposal.accept_proposal(p).should be_nil      


  end

end
