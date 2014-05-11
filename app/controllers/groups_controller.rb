class GroupsController < ApplicationController

  def index
    render 'index', :layout => false
  end

  def next_round
    @group = Group.find(params[:id])
    @group.next_round(params[:user_id].to_i)
    render :json => @group
  end  
end