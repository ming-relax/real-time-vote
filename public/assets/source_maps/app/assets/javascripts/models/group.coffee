class App.Models.Group extends Backbone.Model
    defaults:
      users: (null for _ in [1..3])
      total_earnigs: (0 for _ in [1..3])
      last_earnings: (0 for _ in [1..3])
      deal: null
      is_sync: true

    # initialize: ->
    #   @listenTo App.Vent, 'push:group:start', @group_start

    # group_start: (room_id, group_id) ->
    #   App.currentUser.set 'group_id', group_id
    #   App.currentUser.set 'round_id', 0    
