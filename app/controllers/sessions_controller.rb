class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    if @user = login(params[:user][:username], params[:user][:password])
      redirect_to controller: 'vote', action: 'index'
    else
      flash.now[:alert] = 'Login failed'
      render "sessions/new"
    end
  end

  def destroy
    logout
    redirect_to root_url
  end
end