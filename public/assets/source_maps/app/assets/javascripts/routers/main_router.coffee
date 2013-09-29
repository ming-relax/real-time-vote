class App.Routers.MainRouter extends Backbone.Router
  routes:
    "": "rooms"
    "rooms": "rooms"
    "group": "group"
    "login": "login"
    "logout": "logout"
    "group": "group"
    "signup": "signup"

  initialize: ->
    @headerView = new App.Views.Header()
    @contentView = new App.Views.Content()

  signup: ->
    @layoutViews()
    App.Vent.trigger "user:signup"
    
  login: ->
    @layoutViews()
    App.Vent.trigger "user:login"
    

  logout: ->
    @layoutViews()
    App.Vent.trigger "user:logged_out"



  # Load room page
  rooms: ->
    # if App.currentUser.is_group_valid()
    #   App.Vent.trigger 'group:start'
    # else
    #   @layoutViews()
    #   App.Vent.trigger "rooms:init"

    @layoutViews()
    App.Vent.trigger "rooms:init"

  group: ->
    @layoutViews()
    console.log 'route #group'
    if App.currentUser.is_group_valid()
      App.Vent.trigger "group:start"
    else
      App.Vent.trigger "room:init"

  layoutViews: ->
    $('#header').html(@headerView.render().el)
    $('#content').html(@contentView.render().el)

