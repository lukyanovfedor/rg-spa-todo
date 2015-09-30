describe 'ProjectsController', () ->
  $rootScope = null
  $scope = null

  MockNotifications = {}
  MockTemplate = {}

  injectorFn = (_$rootScope_, _$controller_) ->
    $rootScope = _$rootScope_
    $scope = _$rootScope_.$new()

    projects = []

    _$controller_('ProjectsController as projectsCtrl', { $scope: $scope, projects: projects })

  beforeEach(module('TodoApp'))

  beforeEach(module(($provide) ->
    $provide.factory('Notifications', () ->
      MockNotifications
    )

    $provide.factory('Template', () ->
      MockTemplate
    )

    return undefined
  ))

  beforeEach(() ->
    simple.mock(MockNotifications, 'success')

    simple.mock(MockTemplate, 'setTitle').returnWith(MockTemplate)
    simple.mock(MockTemplate, 'setBodyClasses').returnWith(MockTemplate)

    inject(injectorFn)
  )

  it 'expect to receive setTitle', () ->
    expect(MockTemplate.setTitle.called).to.be.true

  it 'expect to receive setBodyClasses', () ->
    expect(MockTemplate.setBodyClasses.called).to.be.true

  it 'expect to assign projects', () ->
    expect($scope.projectsCtrl.projects).to.exist

  describe '.edit', () ->
    it 'expect to assign edit function', () ->
      expect($scope.projectsCtrl.edit).to.be.an.instanceof(Function)

    it 'expect to set isEdit', () ->
      project = {}
      $scope.projectsCtrl.edit(project)
      expect(project.isEdit).to.be.true

  describe '.destroyCb', () ->
    it 'expect to assign destroyCb function', () ->
      expect($scope.projectsCtrl.destroyCb).to.be.an.instanceof(Function)

    it 'expect to receive success for Notifications', () ->
      $scope.projectsCtrl.destroyCb()
      expect(MockNotifications.success.called).to.be.true

  describe '.updateCb', () ->
    it 'expect to assign updateCb function', () ->
      expect($scope.projectsCtrl.updateCb).to.be.an.instanceof(Function)

    it 'expect to receive success for Notifications', () ->
      $scope.projectsCtrl.updateCb()
      expect(MockNotifications.success.called).to.be.true
