class App.Models.Room extends Backbone.Model
	defaults:
		empty_seats: null



class App.Collections.Rooms extends Backbone.Collection
	model: App.Models.Room
	url: "/rooms"