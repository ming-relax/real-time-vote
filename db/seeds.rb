# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


Group.destroy_all
Proposal.destroy_all
User.destroy_all

Room.destroy_all
40.times do |i|
	Room.create(users_id: [])
end

User.destroy_all
3.times do |n|
  User.create(username: "ming-#{n+1}", password: '123')
end
