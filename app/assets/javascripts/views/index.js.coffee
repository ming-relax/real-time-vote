class App.Views.Index extends Backbone.View

  template: HandlebarsTemplates['index']
  events:
    "click a": "startGame"


  render: ->
    # console.log 'render index'
    @$el.html(@template())
    @

  startGame: (e) ->
    e.preventDefault()
    App.Vent.trigger 'rooms:init'
