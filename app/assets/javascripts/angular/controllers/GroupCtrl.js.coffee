# myself:
#   id
#   room_id
#   total_earnings
# group:
#   users: [..] username, id, total_earnings
#   betray_penalty
#   status
#   deal: Proposal
# oponents:
#   [..]
#   id,
#   username,
#   proposal_to_me: [2, 2, 98]
#   proposal_from_me: [2, 2, 98]
#   

@vote.controller 'GroupCtrl', ['$scope', '$http', '$location', 'userService', 'userQueryService', 
  ($scope, $http, $location, userService, userQueryService) ->
    
    console.log("GroupCtrl")

    if !userService.hasGroup()
      $location.path('/rooms')
    
    $scope.model = 
      myself: 
        id: null
        room_id: null
        total_earning: null

      group: 
        users: ({username: null, id: null, total_earning: null} for _ in [1..3])
      opponents: ({username: null, proposal_to_me: (null for _ in [1..3]), proposal_from_me: (null for _ in [1..3])} for _ in [1..2])

    $scope.$watch(userQueryService.queryResult, (newVal, oldVal) ->
      console.log('GroupCtrl: newVal: ', newVal, ' oldVal: ', oldVal)
      if newVal
        $scope.model.myself = newVal.myself
        $scope.model.group = newVal.group
        $scope.model.opponents = newVal.opponents
        if $scope.model.group and $scope.model.group.deal
          $scope.model.group.deal.submitterName = $scope.idToName($scope.model.group.deal.submitter)
          $scope.model.group.deal.acceptorName = $scope.idToName($scope.model.group.deal.acceptor)

          # update last earning
          # $scope.model.group.lastEarning = newVal.group.last_earning
    , true)

    if !userQueryService.queryStarted
      userQueryService.start()

    $scope.userIdToIndex = (uid) ->
      userIndex = null
      $scope.model.group.users.forEach (u, index) ->
        if u.id == uid
          userIndex = index
          return
      userIndex

    $scope.idToName = (id) ->
      index = $scope.userIdToIndex(id)
      $scope.model.group.users[index].username
        
    $scope.isAckedByMyself = () ->
      if $scope.model.myself.id and $scope.model.group and $scope.model.group.acked_users.indexOf($scope.model.myself.id) != -1
        true
      else
        false

    $scope.accept = (index) ->
      if $scope.model.group and $scope.model.group.status == 'deal'
        console.log('group status is deal')
        return

      console.log('proposal_to_me: ', $scope.model.opponents[index].proposal_to_me)
      return if !$scope.model.opponents[index].proposal_to_me

      id = $scope.model.opponents[index].proposal_to_me.id
      $http.put(
        "/proposals/accept/#{id}.json",
        {
          group_id: $scope.model.opponents[index].proposal_to_me.group_id
        })
        .success (data, status) =>
          console.log('success: ', data)
        .error (rsp) =>
          console.log('error: ', rsp)

    $scope.nextRound = () ->
      console.log('nextRound')
      group_id = $scope.model.group.id
      $http.put(
        "/groups/#{group_id}/next_round.json",
        {
          user_id: $scope.model.myself.id
        })
        .success (data, status) =>
          console.log('success: ', data)
        .error (rsp) =>
          console.log('error: ', rsp)
]

# :group_id, :round_id, :submitter, :acceptor, :moneys
@vote.controller 'MyProposalCtrl', ['$scope', '$http', ($scope, $http) ->
  console.log("MyProposalCtrl")
  $scope.proposal_from_me = (null for _ in [1..3])
  $scope.submit = () ->
    
    console.log('MyProposalCtrl: submit')

    if $scope.model.group.status == 'deal'
      console.log('group status is deal')
      return
    
    moneys = $scope.proposal_from_me.map (m) -> 
      parseInt(m)

    sum = moneys.reduce (t, s) -> t + s
    if sum != 100
      alert("sum of money should be 100")
      return
    
    $http.post(
      'proposals/submit.json', 
      { 
        group_id: $scope.model.group.id,
        round_id: $scope.model.group.round_id,
        submitter: $scope.model.myself.id,
        acceptor: $scope.model.opponents[$scope.$index].id,
        moneys: moneys
      })
      .success (data, status) =>
        console.log('success: ', data)
        $scope.model.opponents[$scope.$index].proposal_from_me = data.moneys

      .error (rsp) =>
        console.log('error: ', rsp)

]