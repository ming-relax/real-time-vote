def json_rsp
	JSON.parse(response.body)
end

def create_3_users
  users = []
  3.times do |i|
    users << FactoryGirl.create(:user, username: "test#{i}")  
  end
  users
end
