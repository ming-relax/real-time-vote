class App.Models.Opponent extends Backbone.Model
  defaults:
    users: (null for _ in [1..3])
    proposal: null


  receive_proposal: (p) ->
    @set 'proposal', p

class App.Collections.Opponents extends Backbone.Collection
  model: App.Models.Opponent

  initialize: ->
    @listenTo App.Vent, 'push:group:proposal', @receive_proposal
    @.add({})
    @.add({})
    current_user_id = App.currentUser.get('id')
    users = App.currentUser.get('group_users')
    users = _.filter users, (u) -> u != current_user_id
    @.at(0).set('opponent_id', users[0])
    @.at(1).set('opponent_id', users[1])


  receive_proposal: (group_id, proposal) ->
    s = @.find (m) ->
        m.get('opponent_id') is proposal.submitter
    if s
      s.receive_proposal proposal