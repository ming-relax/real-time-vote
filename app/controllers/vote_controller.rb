class VoteController < ApplicationController
  before_action :require_login
  # this is the main page for angular applicaiton
  def index
    gon.user_info = current_user
    render :index
  end
end
