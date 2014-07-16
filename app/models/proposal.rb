class Proposal < ActiveRecord::Base
  belongs_to :group
  
  validates :group_id, :round_id, :submitter, :acceptor, numericality: { only_integer: true }
  validate :sum_of_moneys, on: :create

  def sum_of_moneys
    puts self
    sum = moneys.inject {|sum,x| sum + x }
    errors.add(:moneys, 'sum of money should be 100') if sum != 100   
  end

  def self.deal(group_id, round_id)
    Proposal.where("group_id = :group_id AND round_id = :round_id AND accepted = :accepted", 
                   {group_id: group_id, round_id: round_id, accepted: true})
            .first
  end

  def self.previous_deal(group_id, round_id)
    Proposal.where("group_id = :group_id AND round_id = :round_id AND accepted = :accepted", 
                   {group_id: group_id, round_id: round_id - 1, accepted: true})
            .first
  end

  def self.to_me(group, user_id)
    proposals = Proposal.where("group_id = :group_id AND round_id = :round_id AND acceptor = :user_id",
                               {group_id: group.id, round_id: group.round_id, user_id: user_id})
                        .order(created_at: :desc)


    users_id = group.users_id
    others = users_id.select { |id| id != user_id }    
    proposals = others.map do |other|
      proposals.find { |p| p.submitter == other}
    end
    proposals
  end

  # POST submit
  def self.submit(options)
    self.transaction do
      group = Group.lock(true).find(options[:group_id])
      raise "Dealed" if group.status != 'active'
      Proposal.create!(options)
    end
  end

  def self.accept(options)
    self.transaction do
      group = Group.lock(true).find(options[:group_id])
      raise "Dealed" if group.status != 'active'

      proposal = Proposal.find(options[:id])

      # update each user's earnings
      submitter_penalty, acceptor_penalty, moneys = group.update_earnings(proposal)

      # update group
      new_moneys = group.moneys.map.with_index do |e, i|
        e + moneys[i]
      end

      # dont update round_id for now
      # wait until all users acked
      group.update!(moneys: new_moneys,
               status: 'deal')
      # update proposal
      proposal.update!(accepted: true, 
                       submitter_penalty: submitter_penalty, 
                       acceptor_penalty: acceptor_penalty)
      deal = proposal
      deal.moneys = moneys
      if Rails.env.development?
        OfflineChecker.perform_in(20.seconds, group.id, group.round_id)
      else
        OfflineChecker.perform_in(1.minute, group.id, group.round_id)
      end
      return [deal, new_moneys]
    end
  end
end