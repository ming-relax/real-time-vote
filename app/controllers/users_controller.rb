class UsersController < ApplicationController

  def create
    begin
      @user = User.create!(username: params[:username], 
                           password: params[:password],
                           weibo: params[:weibo])   
    rescue ActiveRecord::RecordInvalid => e
      render :json => {:error => "username was taken"}, :status => 422
    end
  end

  # only update round_id
  def update
    @user, @is_group_sync, @is_myself_sync = User.next_round(params[:id])
  end


  def query
    @user_info = User.query_user(params[:id].to_i)
    render :json => @user_info
  end

  private
    def user_param
    params.require(:user).permit(:username, :password)
    end
end