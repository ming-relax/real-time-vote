class GroupsController < ApplicationController
  def update
    Group.exit_group(params[:id], params[:user_id])
  end
end