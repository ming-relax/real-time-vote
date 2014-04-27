@vote.controller 'RoomIndexCtrl', ['$scope', '$location', '$http', 'userService', 'userQueryService', 
  ($scope, $location, $http, userService, userQueryService) ->

    if userService.hasGroup()
      $location.path('/group')
      
    $scope.rooms = []
    $http.get('./rooms.json').success((data) ->
      $scope.rooms = data.rooms
    )

    $scope.joinRoom =  (index) ->
      console.log("index: ", index)
      user = userService.currentUser()
      if user
        console.log("room_id: ", $scope.rooms[index].id)
        $http.put("./rooms/join.json", {room_id: $scope.rooms[index].id, user_id: user.id})
      else
        $location.path('/')


    # query ./rooms.json every second
    setInterval(( ->
      $http.get('./rooms.json').success((data) ->
        $scope.rooms = data.rooms)
    ), 1000)

    $scope.$watch(userQueryService.group, (group, old) ->
      if group
        console.log('RoomIndexCtrl have group')
        console.log('group: ', group)
        $location.path('/group')     
    , true)
]
