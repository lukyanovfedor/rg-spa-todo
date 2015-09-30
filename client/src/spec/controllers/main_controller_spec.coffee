describe 'MainController', () ->
  $rootScope = null
  $scope = null

  MockNotifications = {}
  MockState = {}

  injectorFn = (_$rootScope_, _$controller_) ->
    $rootScope = _$rootScope_
    $scope = _$rootScope_.$new()

    _$controller_('MainController as mainCtrl', { $scope: $scope })

  beforeEach(module('TodoApp'))

  beforeEach(module(($provide) ->
    $provide.factory('Notifications', () ->
      MockNotifications
    )

    $provide.service('$state', () ->
      MockState
    )

    return undefined
  ))

  beforeEach(() ->
    simple.mock(MockNotifications, 'getCurrent').returnWith([])
    simple.mock(MockNotifications, 'remove').returnWith([])
    simple.mock(MockState, 'go')

    inject(injectorFn)
  )

  it 'expect to assigns a Template', () ->
    expect($scope.mainCtrl).to.have.property('Template')

  describe '.notifications', () ->
    it 'expect to assigns a notifications', () ->
      expect($scope.mainCtrl).to.have.property('notifications')

    it 'expect to receive .getCurrent for Notifications', () ->
      expect(MockNotifications.getCurrent.called).to.be.true

  describe '.removeNotification', () ->
    it 'expect to assigns a removeNotification with function', () ->
      expect($scope.mainCtrl.removeNotification).to.be.an.instanceof(Function)

    it 'expect to receive a remove for Notifications', () ->
      $scope.mainCtrl.removeNotification()
      expect(MockNotifications.remove.called).to.be.true

  describe '.events', () ->
    it 'expect to redirect to auth, on auth:logout-success', () ->
      $rootScope.$broadcast('auth:logout-success')
      expect(MockState.go.lastCall.arg).to.equal('auth')

    it 'expect to redirect to auth, on auth:validation-error', () ->
      $rootScope.$broadcast('auth:validation-error')
      expect(MockState.go.lastCall.arg).to.equal('auth')

    it 'expect to redirect to auth, on auth:invalid', () ->
      $rootScope.$broadcast('auth:invalid')
      expect(MockState.go.lastCall.arg).to.equal('auth')

    it 'expect to redirect to taskboard.projects, on auth:login-success', () ->
      $rootScope.$broadcast('auth:login-success')
      expect(MockState.go.lastCall.arg).to.equal('taskboard.projects')

    it 'expect to redirect to taskboard.projects, on auth:registration-email-success', () ->
      $rootScope.$broadcast('auth:registration-email-success')
      expect(MockState.go.lastCall.arg).to.equal('taskboard.projects')
