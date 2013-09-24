class App.Routers.MainRouter extends Backbone.Router
  routes:
    "": "rooms"
    "rooms": "rooms"
    "group": "group"
    "login": "login"
    "logout": "logout"
    "group": "group"


  initialize: ->
    @headerView = new App.Views.Header()
    @contentView = new App.Views.Content()

  # Game rule, start button
  index: ->
    @layoutViews()
    App.Vent.trigger "vote:init"
    
  login: ->
    @layoutViews()
    App.Vent.trigger "user:login"
    

  logout: ->
    @layoutViews()
    App.Vent.trigger "user:logged_out"

  # Load room page
  rooms: ->
    @layoutViews()
    App.Vent.trigger "rooms:init"

  group: ->
    @layoutViews()
    console.log 'route #group'
    group_id = App.currentUser.get 'group_id'
    if group_id isnt -1
      App.Vent.trigger "group:start"

  layoutViews: ->
    $('#header').html(@headerView.render().el)
    $('#content').html(@contentView.render().el)

