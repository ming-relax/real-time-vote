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

      userService.joinRoom($scope.rooms[index].id)
        .then () ->
          if userService.hasGroup()
            $location.path('/group')

    # $scope.$watch(userService.group, (newValue, oldValue) ->
    #   if userService.hasGroup()
    #     $location.path('/group')
    # , true)

    # query ./rooms.json every second
    setInterval(( ->
      $http.get('./rooms.json').success((data) ->
        $scope.rooms = data.rooms)
    ), 1000)

    $scope.$watch(userQueryService.queryResult, (newValue, oldValue) ->
      if newValue and newValue.group
        # must set group id to prevent redirect loop
        userService.groupId(newValue.group.id)
        $location.path('/group')     
    , true)
]
