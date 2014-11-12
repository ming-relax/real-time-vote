class UsersController < ApplicationController

  def new
    @user = User.new

  end

  def create
    params[:user][:weibo] = params[:user][:username]
    @user = User.new(user_param)
    if @user.save
      auto_login(@user)
      redirect_to controller: 'vote', action: 'index'
    else
      render 'users/new'
    end
  end

  # only update round_id
  def update
    @user, @is_group_sync, @is_myself_sync = User.next_round(params[:id])
  end


  def query
    @user_info = User.query_user(params[:id], params[:group_id], params[:round_id])
    render :json => @user_info
  end

  private
    def user_param
    params.require(:user).permit(:username, :password, :email, :weibo)
    end
end