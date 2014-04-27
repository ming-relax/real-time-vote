@vote.controller 'NavbarCtrl', ['$scope', '$rootScope', 'userService', '$location', 
  ($scope, $rootScope, userService, $location) ->  

    console.log('NavbarCtrl')
    
    $scope.isLoggedIn = userService.isLoggedIn()
    
    $scope.$watch(userService.isLoggedIn, (newValue, oldValue) ->
      console.log('NavbarCtrl: isLoggedIn: ', newValue)
      $scope.isLoggedIn = newValue
      if $scope.isLoggedIn == true
        $scope.username = userService.currentUser().username
    )

    $scope.logout = () ->
      console.log('click logout')
      userService.logout()
        .then () ->
          $location.path("/")

]