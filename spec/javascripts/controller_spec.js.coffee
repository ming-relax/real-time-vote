describe "Vote controllers", ->
  beforeEach module("vote")

  describe "RoomIndexCtrl", ->
    it "should set rooms to an empty array", inject(($controller) ->
      scope = {}
      ctrl = $controller("RoomIndexCtrl",
        $scope: scope)
      expect(scope.rooms.length).toBe 0
    )