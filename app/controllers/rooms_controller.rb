class RoomsController < ApplicationController
  
  def index
    # all_rooms = Room.all
    # @rooms = all_rooms.sort_by do |r|
    #   r.id % Room.count - params[:user_id].to_i % Room.count
    # end
    # all_rooms = Room.all
    # ary = all_rooms.shift(params[:user_id].to_i % Room.count)
    # @rooms = all_rooms + ary
    all_rooms = Room.all.sort
    ary = all_rooms.shift(params[:user_id].to_i % Room.count)
    @rooms = all_rooms + ary
  end

  def template
    render 'template', :layout => false
  end

  def join
    room_id = params[:room_id].to_i
    user_id = params[:user_id].to_i
    begin
      @user = Room.join(room_id, user_id)
    rescue RoomError => e
      render :json => {:errors => e.message}, :status => 424
    end
  end

  def leave
    room_id = params[:room_id].to_i
    user_id = params[:user_id].to_i
    begin
      @users, @group_id = Room.leave(room_id, user_id)
    rescue RoomError => e
      puts e.message
      render :json => {:errors => e.message}, :status => 424
    end
    
  end

end
