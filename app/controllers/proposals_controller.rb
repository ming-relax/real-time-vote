class ProposalsController < ApplicationController
  def index

  end

  def create
    @proposal = Proposal.create proposal_param
    Pusher.proposal(@proposal)

    respond_with(@proposal)
  end

  def update
    # begin
    #   p = Porposal.accept_proposal(params[:proposal])
    #   Pusher.deal(p)
    #   respond_with(p)
    # rescue Exception => e
    #   respond_with({:err => 'accept error'})      
    # end

    @deal, @group_moneys = Proposal.accept_proposal(params[:proposal])

    Pusher.deal(@deal, @group_moneys)
    
    respond_with(@deal, @group_moneys)
     
  end

  private

  def proposal_param
    params.require(:proposal).permit(:id,
                                     :group_id, 
                                     :round_id, 
                                     :submitter, 
                                     :acceptor, 
                                     {:moneys => []}, 
                                     :accepted, 
                                     :submitter_penalty, 
                                     :acceptor_penalty)
  end
end