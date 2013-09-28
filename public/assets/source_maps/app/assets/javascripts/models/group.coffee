class App.Models.Group extends Backbone.Model
    defaults:
      round_id: null
      # group member's info
      # [{id: xx, username: xx}, ...]
      users: null
      # group member's earning in this group
      moneys: null
      
      betray_penalty: null

      last_deal: null
      
      current_deal: null

      # start, deal, wait_others
      state: "invalid"

    init_group_state: ->
      current_deal = @get 'current_deal' 
      is_group_sync = App.currentUser.get 'is_group_sync'
      is_myself_sync = App.currentUser.get 'is_myself_sync'

      state = "invalid"
      
      if is_group_sync is false and is_myself_sync is false
        state = "deal"

      else if is_group_sync is false and is_myself_sync is true
        state = "wait_others"
      else if is_group_sync is true and is_myself_sync is true
        state = "start" 

      @set
        state: state

    group_deal: (deal, group_moneys) ->
      curernt_deal = @get('current_deal')
      @set
        last_deal: curernt_deal
        current_deal: deal
        moneys: group_moneys
        state: "deal"


    group_sync: (round_id) ->
      current_deal = @get 'current_deal'
      state = @get 'state'
      if state is "deal"
        @set
          round_id: round_id,
          last_deal: current_deal
          current_deal: null,
          state: "start"
      else if state is "wait_others"
        @set
          round_id: round_id
          state: "start"
        
      App.currentUser.set
        is_group_sync: true

    group_wait: ->
      current_deal = @get('current_deal')
      @set
        last_deal: current_deal
        current_deal: null
        state: "wait_others"

      # redundant code
      App.currentUser.set
        is_group_sync: false
        is_myself_sync: true
