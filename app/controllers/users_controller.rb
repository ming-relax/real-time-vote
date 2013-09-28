class UsersController < ApplicationController

  # only update round_id
  def update
    @user, @is_group_sync, @is_myself_sync = User.next_round(params[:id])
  end
end