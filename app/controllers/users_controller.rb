class UsersController < ApplicationController

  # only update round_id
  def update
    @user, @is_sync = User.next_round(params[:id])
  end
end