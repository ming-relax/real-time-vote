# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/














I18n.defaultLocale = "en"
I18n.locale = "cn"

Handlebars.registerHelper "t", (msg) -> I18n.t msg

window.App =
  Routers: {}
  Views: {}
  Collections: {}
  Models: {}
  Vent: _.clone(Backbone.Events)
  initialize: (data)->
    App.env = data.env
    App.currentUser = new App.Models.CurrentUser(data.user_info)
    App.listener = new App.Listener()
    new App.Routers.MainRouter()
    Backbone.history.start()


    
