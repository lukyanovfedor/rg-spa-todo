describe 'TaskController', () ->
  $rootScope = null
  $scope = null
  $httpBackend = null

  MockNotifications = {}

  injectorFn = (_$rootScope_, _$controller_, _$httpBackend_) ->
    $rootScope = _$rootScope_
    $scope = _$rootScope_.$new()
    $httpBackend = _$httpBackend_

    _$controller_('TasksController as tasksCtrl', { $scope: $scope })

  beforeEach(module('TodoApp'))

  beforeEach(module(($provide) ->
    $provide.factory('Notifications', () ->
      MockNotifications
    )

    return undefined
  ))

  beforeEach(() ->
    simple.mock(MockNotifications, 'success')

    inject(injectorFn)
  )

  it 'expect to assign newTask', () ->
    expect($scope.tasksCtrl.newTask).to.exist

  describe '.formatDeadline', () ->
    it 'expect to assign formatDeadline function', () ->
      expect($scope.tasksCtrl.formatDeadline).to.be.an.instanceof(Function)

    it 'expect to return task deadline in format DD MMM YY', () ->
      task = { deadline: new Date(0) }
      expect($scope.tasksCtrl.formatDeadline(task)).to.equal('01 Jan 70')

  describe '.isExpired', () ->
    it 'expect to assign isExpired function', () ->
      expect($scope.tasksCtrl.isExpired).to.be.an.instanceof(Function)

    it 'expect to return false, if task deadline date bigger then today', () ->
      task = { deadline: new Date(new Date().valueOf() + 86400000) }
      expect($scope.tasksCtrl.isExpired(task)).to.be.false

    it 'expect to return false, if task deadline date less then today', () ->
      task = { deadline: new Date(new Date().valueOf() - 86400000) }
      expect($scope.tasksCtrl.isExpired(task)).to.be.true

  describe '.toggle', () ->
    it 'expect to assign toggle function', () ->
      expect($scope.tasksCtrl.toggle).to.be.an.instanceof(Function)

    it 'expect to change task into server response state', () ->
      task = { id: 1 }
      $httpBackend.expectPUT('/tasks/1/toggle.json').respond(angular.toJson({ state: 'server_state' }))
      $scope.tasksCtrl.toggle(task)
      $httpBackend.flush()
      expect(task.state).to.equal('server_state')

  describe '.createTask', () ->
    project = null
    form = null

    beforeEach(() ->
      project = { id: 1, tasks: [] }
      form = {
        $setPristine: () ->
      }
      $scope.tasksCtrl.form = form
      $httpBackend.expectPOST('/projects/1/tasks.json').respond($scope.tasksCtrl.newTask.toJSON())
    )

    it 'expect to assign createTask function', () ->
      expect($scope.tasksCtrl.createTask).to.be.an.instanceof(Function)

    it 'expect to assign project_id to new task', () ->
      form.$invalid = false
      $scope.tasksCtrl.createTask(project)
      expect($scope.tasksCtrl.newTask.project_id).to.equal(1)

    it 'expect to do nothing if form is invalid', () ->
      form.$invalid = true
      $scope.tasksCtrl.createTask(project)
      expect($scope.tasksCtrl.newTask.project_id).not.to.exist

    it 'expect to add new task to project tasks, when task created', () ->
      form.$invalid = false
      $scope.tasksCtrl.createTask(project)
      $httpBackend.flush()
      expect(project.tasks.length).to.equal(1)

    it 'expect to receive success for Notifications', () ->
      form.$invalid = false
      $scope.tasksCtrl.createTask(project)
      $httpBackend.flush()
      expect(MockNotifications.success.called).to.be.true

  describe '.dragAndDropCb', () ->
    it 'expect to assign dragAndDropCb object', () ->
      expect($scope.tasksCtrl.dragAndDropCb).to.be.an.instanceof(Object)

    it 'expect to have orderChanged handler', () ->
      expect($scope.tasksCtrl.dragAndDropCb.orderChanged).to.be.an.instanceof(Function)


