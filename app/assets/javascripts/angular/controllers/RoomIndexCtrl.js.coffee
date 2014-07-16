@vote.controller 'RoomIndexCtrl', ['$scope', '$location', '$http', 'userService', 'userQueryService', 
  ($scope, $location, $http, userService, userQueryService) ->

    if userService.hasGroup()
      $location.path('/group')

    $scope.rooms = []
    $http.get('./rooms.json').success((data) ->
      $scope.rooms = data.rooms
    ).then () ->
      $scope.selected = "unselect" for _ in [1..$scope.rooms.length]


    $scope.joinRoom =  (index) ->
      console.log("index: ", index)

      userService.joinRoom($scope.rooms[index].id)
        .then () ->
          $scope.selected = 'selected'
          if userService.hasGroup()
            $location.path('/group')


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
