class Proposal < ActiveRecord::Base
  belongs_to :group
  validates_presence_of :group_id, :round_id, :submitter, :acceptor, :moneys, :submitter_penalty, :acceptor_penalty
  validates_inclusion_of :accepted, :in => [true, false]
  # after_commit :push_decision, :on => :update
  after_rollback :accept_fail

  # use redis to store accepted proposal
  def self.current_round_is_over?(round_id, group_id)
    proposals = Proposal.where('group_id = ? AND round_id = ? AND accepted = ?',
                                group_id, round_id, true)
    if proposals.length > 0
      true
    else
      false
    end

  end

  # several states need to be updated:
  # 1) proposal --- accepted
  # 2) proposal --- submitter_penalty, acceptor_penalty
  # 3) user     --- total_earnings
  # 4) group    --- round_id
  # 5) group    --- moneys
  def self.accept_proposal(params)
    return "error:round:over" if current_round_is_over?(params[:round_id], params[:group_id])
    
    proposal = nil
    new_monyes = [0, 0, 0]
    self.transaction do
      proposal = Proposal.find(params[:id])

      g = Group.find(proposal.group_id)

      # update each user's earnings
      submitter_penalty, acceptor_penalty, moneys = g.update_earnings(proposal)

      # update group
      
      g.moneys.each_index do |i|
        new_monyes[i] = g.moneys[i] + moneys[i]
      end
      g.update!(moneys: new_monyes, 
               round_id: g.round_id + 1)      

      # update proposal
      proposal.update!(accepted: true, 
                       submitter_penalty: submitter_penalty, 
                       acceptor_penalty: acceptor_penalty)
    end

    return [proposal, new_monyes]    
  end

  def push_decision
    # puts "after_commit: proposal id #{id}"
    # Pusher.decision()
  end

  def accept_fail
    puts '*'*30
    puts "after_rollback: proposal id #{id}"
  end

end