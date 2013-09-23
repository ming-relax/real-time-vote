class App.Views.Content extends Backbone.View
  className: "container"

  template: HandlebarsTemplates['content']  
  
  initialize: ->
    @listenTo App.Vent, "vote:init", @swapToIndex

    # fetch room data
    @listenTo App.Vent, "rooms:init", @initRooms

    # room data has fetched, we should render it
    @listenTo App.Vent, "rooms:ready", @swapToRooms
    @listenTo App.Vent, "user:login", @swapToLogin

    # we have enough pepole, let's show the game page
    @listenTo App.Vent, 'group:start', @swapGroup

  swapToIndex: ->
    @swapSubView(new App.Views.Index())
    Backbone.history.navigate("/")


  initRooms: ->
    new App.Views.Rooms({collection: new App.Collections.Rooms()})

  swapGroup: (room_id, group_id, group_users) ->
    console.log 'content swapGroup'
       
    group_users.sort()
    App.currentUser.set 'group_users', group_users
    App.currentUser.set 'room_id', room_id
    App.currentUser.set 'group_id', group_id
    App.currentUser.set 'round_id', 0    
    @swapSubView(new App.Views.Group({model: new App.Models.Group({room_id: room_id, users: group_users})}))
    Backbone.history.navigate("/group")
    console.log 'group_init done!'

  swapToRooms: (v) ->
    @swapSubView(v)
    Backbone.history.navigate("/rooms")


  swapToLogin: ->
    @swapSubView(new App.Views.Login({model: new App.Models.Login()}))


  swapSubView: (v) ->
    @subView.remove() if @subView
    @subView = v
    @$('#main-area').html(@subView.render().el)
  
  render: ->
    @$el.html(@template())
    @


