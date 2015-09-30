describe 'TaskController', () ->
  $rootScope = null
  $scope = null

  task = {}
  comments = []

  MockNotifications = {}
  MockTemplate = {}
  MockState = {}
  MockComments = {}

  injectorFn = (_$rootScope_, _$controller_) ->
    $rootScope = _$rootScope_
    $scope = _$rootScope_.$new()

    projects = []

    _$controller_('TaskController as taskCtrl', { $scope: $scope, task: task, comments: comments })

  beforeEach(module('TodoApp'))

  beforeEach(module(($provide) ->
    $provide.factory('Notifications', () ->
      MockNotifications
    )

    $provide.factory('Template', () ->
      MockTemplate
    )

    $provide.service('$state', () ->
      MockState
    )

    $provide.factory('Comments', () ->
      MockComments
    )

    return undefined
  ))

  beforeEach(() ->
    simple.mock(MockNotifications, 'success')

    simple.mock(MockTemplate, 'setTitle').returnWith(MockTemplate)
    simple.mock(MockTemplate, 'setBodyClasses').returnWith(MockTemplate)

    simple.mock(MockState, 'go')

    simple.mock(MockComments, 'setComments')

    inject(injectorFn)
  )

  it 'expect to receive setTitle', () ->
    expect(MockTemplate.setTitle.called).to.be.true

  it 'expect to receive setBodyClasses', () ->
    expect(MockTemplate.setBodyClasses.called).to.be.true

  it 'expect to assign task', () ->
    expect($scope.taskCtrl.task).to.exist

  it 'expect to assign comments', () ->
    expect($scope.taskCtrl.comments).to.exist

  it 'expect to receive setComments with comments, for Comments', () ->
    expect(MockComments.setComments.lastCall.arg).to.equal(comments)

  describe '.edit', () ->
    it 'expect to assign edit function', () ->
      expect($scope.taskCtrl.edit).to.be.an.instanceof(Function)

    it 'expect to set isEdit', () ->
      $scope.taskCtrl.edit(task)
      expect(task.isEdit).to.be.true

  describe '.destroyCb', () ->
    it 'expect to assign destroyCb function', () ->
      expect($scope.taskCtrl.destroyCb).to.be.an.instanceof(Function)

    it 'expect to receive success for Notifications', () ->
      $scope.taskCtrl.destroyCb()
      expect(MockNotifications.success.called).to.be.true

    it 'expect to receive go for state', () ->
      $scope.taskCtrl.destroyCb()
      expect(MockState.go.called).to.be.true

    it 'expect to call go with taskboard.projects', () ->
      $scope.taskCtrl.destroyCb()
      expect(MockState.go.lastCall.arg).to.equal('taskboard.projects')

  describe '.updateCb', () ->
    it 'expect to assign updateCb function', () ->
      expect($scope.taskCtrl.updateCb).to.be.an.instanceof(Function)

    it 'expect to receive success for Notifications', () ->
      $scope.taskCtrl.updateCb()
      expect(MockNotifications.success.called).to.be.true
