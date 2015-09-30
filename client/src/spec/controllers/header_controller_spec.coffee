describe 'HeaderController', () ->
  $scope = null

  MockAuth = {}
  MockProjects = {}
  MockState = {}

  Notifications = null

  injectorFn = (_$rootScope_, _$controller_, _$q_, _Notifications_) ->
    simple.Promise = _$q_
    $scope = _$rootScope_.$new()
    Notifications = _Notifications_

    _$controller_('HeaderController as headerCtrl', { $scope: $scope })

  beforeEach(module('TodoApp'))

  beforeEach(module(($provide) ->
    $provide.provider('$auth', () ->
      return {
        configure: () ->
        $get: () ->
          MockAuth
      }
    )

    $provide.factory('Projects', () ->
      MockProjects
    )

    $provide.service('$state', () ->
      MockState
    )

    return undefined
  ))

  beforeEach(() ->
    simple.mock(MockAuth, 'initialize')
    simple.mock(MockAuth, 'signOut')

    inject(injectorFn)
  )

  it 'expect to assigns a user', () ->
    expect($scope.headerCtrl).to.have.property('user')

  describe '.signOut', () ->
    it 'expect to assigns a signOut', () ->
      expect($scope.headerCtrl.signOut).to.be.an.instanceOf(Function)

    it 'expect to receive signOut', () ->
      $scope.headerCtrl.signOut()
      expect(MockAuth.signOut.called).to.be.true

  describe '.createProject', () ->
    beforeEach(() ->
      simple.mock(MockProjects, 'newProjectModal').resolveWith({})
      simple.mock(MockState, 'is').returnWith(false)
      simple.mock(MockState, 'go')
    )

    it 'expect to assigns a createProject', () ->
      expect($scope.headerCtrl.createProject).to.be.an.instanceOf(Function)

    it 'expect to receive newProjectModal', () ->
      $scope.headerCtrl.createProject()
      expect(MockProjects.newProjectModal.called).to.be.true

    it 'expect to add notification, if modal resolved', () ->
      $scope.headerCtrl.createProject()
      $scope.$digest()
      expect(Notifications.getCurrent().length).to.equal(1)

    it 'expect to redirect to "taskboard.projects", if state is not "taskboard.projects"', () ->
      $scope.headerCtrl.createProject()
      $scope.$digest()
      expect(MockState.go.called).to.be.true
