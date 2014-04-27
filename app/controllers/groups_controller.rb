class GroupsController < ApplicationController
  # def update
  #   Group.exit_group(params[:id], params[:user_id])
  # end


  def next_round
    @group = Group.find(params[:id])
    @group.next_round(params[:user_id].to_i)
    render :json => @group
  end  
end