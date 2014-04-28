@vote.controller 'UserAuthCtrl', ['$scope', 'userService', 'userQueryService', '$location', 
  ($scope, userService, userQueryService, $location) ->
    console.log('UserAuthCtrl: isLoggedIn: ', userService.isLoggedIn())

    $scope.redirect_to_game = () ->
      if userService.hasGroup()
        $location.path("/group")
      else
        $location.path("/rooms")

    $scope.isLoggedIn = userService.isLoggedIn()
    if $scope.isLoggedIn
      $scope.redirect_to_game()

    # events and model data
    $scope.displaySignup = false
    $scope.login = () ->
      userService.login($scope.username, $scope.password)
        .then () ->
          userQueryService.start()
          $scope.redirect_to_game()

    $scope.signup = () ->
      console.log('signup')
      if $scope.password != $scope.password_confirmation
        alert('password confirmation wrong')
      else
        userService.signup($scope.username, $scope.weibo, $scope.password)
          .then () ->
            $scope.redirect_to_game()
            userQueryService.start()

    $scope.loadSignup = () ->
      console.log("loadSignup")
      $scope.displaySignup = true

    $scope.loadLogin = () ->
      $scope.displaySignup = false

]