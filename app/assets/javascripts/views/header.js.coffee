class App.Views.Header extends Backbone.View
  className: "container"
  template: HandlebarsTemplates['header']

  initialize: ->
    @listenTo App.currentUser, "change:loggedIn", @render

  render: ->
    @$el.html(@template({current_user: App.currentUser.get("loggedIn"), username: App.currentUser.get("username")}))
    @