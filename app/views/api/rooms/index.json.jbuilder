json.rooms do
	json.array! @rooms do |room|
		json.id room.id
		json.seats 3 - room.users_id.length
	end
end