class Api::ProposalsController < ApplicationController
  respond_to :json

  def index

  end

  def submit
    @proposal = Proposal.create! proposal_param
  end

  def accept
    @deal, @group_moneys = Proposal.accept(
      :id => params[:id], 
      :group_id => params[:group_id]
    )
  end

  private

  def proposal_param
    params.require(:proposal).permit(:id,
                                     :group_id, 
                                     :round_id, 
                                     :submitter, 
                                     :acceptor,  
                                     :accepted, 
                                     :submitter_penalty, 
                                     :acceptor_penalty).tap do |whitelisted|
                                       whitelisted[:moneys] = params[:proposal][:moneys]
                                     end
  end
end