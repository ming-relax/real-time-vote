class App.Models.Opponent extends Backbone.Model
  defaults:
    users: (null for _ in [1..3])


class App.Collections.Opponents extends Backbone.Collection
  model: App.Models.Opponent

  initialize: ->
    @.add({})
    @.add({})
    current_user_id = App.currentUser.get('id')
    opponents = App.currentUser.opponents()

    @.at(0).set('id', opponents[0].id)
    @.at(1).set('id', opponents[1].id)