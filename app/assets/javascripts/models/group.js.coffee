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
      is_sync = App.currentUser.get 'is_sync'

      state = "invalid"
      

      # just received the deal
      if current_deal and is_sync
        state = "deal"

      else if !current_deal and is_sync
        state = "start"

      else if current_deal and !is_sync
        state = "wait_others"

      @set
        state: state

    group_deal: (deal) ->
      curernt_deal = @get('current_deal')
      @set
        last_deal: curernt_deal,
        current_deal: deal,
        state: "deal"


    group_sync: (round_id) ->
      current_deal = @get 'current_deal'
      @set
        round_id: round_id,
        last_deal: current_deal
        current_deal: null,
        state: "start"
      
      App.currentUser.set
        is_sync: true

    group_wait: ->
      @set
        state: "wait_others"

      # redundant code
      App.currentUser.set
        is_sync: false