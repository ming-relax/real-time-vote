# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/












window.App =
  Routers: {}
  Views: {}
  Collections: {}
  Models: {}
  Vent: _.clone(Backbone.Events)
  initialize: (data)->
    App.currentUser = new App.Models.CurrentUser(data)
    App.listener = new App.Listener()
    new App.Routers.MainRouter()
    Backbone.history.start()
    
