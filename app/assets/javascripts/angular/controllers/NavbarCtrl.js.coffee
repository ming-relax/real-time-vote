@vote.controller 'NavbarCtrl', ['$scope', '$rootScope', 'userService', '$location', 
  ($scope, $rootScope, userService, $location) ->  
    
    $scope.isLoggedIn = userService.isLoggedIn()
    
    $scope.$watch(userService.isLoggedIn, (newValue, oldValue) ->
      console.log('NavbarCtrl: isLoggedIn: ', newValue)
      $scope.isLoggedIn = newValue
      if $scope.isLoggedIn == true
        $scope.username = userService.currentUser().username
      else
        $scope.username = null
    )

    $scope.logout = () ->
      console.log('click logout')
      userService.logout()
        .then () ->
          console.log('logged out')
          $location.path("/")

]