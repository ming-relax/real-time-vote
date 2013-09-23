if @user
  json.id @user.id
  json.username @user.username
  if @user.room_id
    json.room_id @user.room_id
  end
  json.loggedIn true
end
