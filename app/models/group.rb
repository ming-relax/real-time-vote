class Group < ActiveRecord::Base
  has_many :users
  has_many :proposals

  # use redis to cache group info
  def self.round_id_sync?(group_id)
    group = Group.find(group_id)
    users = group.users
    users.each do |u|
      return false if u.round_id != group.round_id
    end
    return true
  end

  def penalty(this_id, other_id, round_id)
    if round_id == 0
      0
    else
      last_round = round_id - 1
      last_decision = Proposal.where(group_id: self.id, round_id: last_round, accepted: true).first
      if (!last_decision)
        raise 'Not possible'
      end

      if (last_decision.from == this_id && last_decision.to != other_id)
        return self.betray_penalty
      end

      if (last_decision.to == this_id && last_decision.from != other_id)
        return self.betray_penalty
      end

      return 0

    end
  end

  def update_earnings(p)
    submitter_penalty = 0
    acceptor_penalty = 0
    users = self.users
    users.sort! { |a, b| a.id <=> b.id }
    users.each_index do |i|
      users[i].total_earning += p.moneys[i]
      self.moneys[i] += p.moneys[i]

      if users[i].id == p.acceptor
        acceptor_penalty = penalty(p.acceptor, p.submitter, p.round_id)
        users[i].total_earning -= acceptor_penalty
        self.moneys[i] -= acceptor_penalty
      end

      if users[i].id == p.submitter
        # submiter_penalty = penalty_for_submiter(from_id, to_id, round_id)
        submitter_penalty = penalty(p.submitter, p.acceptor, p.round_id)
        users[i].total_earning -= submitter_penalty
        self.moneys[i] -= submitter_penalty
      end

      users[i].save!
      
    end

    [submitter_penalty, acceptor_penalty, self.moneys]

  end

end
