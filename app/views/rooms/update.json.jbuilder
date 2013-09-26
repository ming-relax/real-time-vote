if @users
  json.users @users
  
  if @group_info
    json.group @group_info
  end
  
end