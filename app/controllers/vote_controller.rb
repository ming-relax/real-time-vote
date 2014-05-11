class VoteController < ApplicationController
  def index
    gon.user_info = current_user
  end

  def login
    render 'login', :layout => false
  end

end
