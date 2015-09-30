describe 'Projects', () ->
  Projects = null
  $q = null
  $rootScope = null

  MockModal = {}

  injectorFn = (_Projects_, _$q_, _$rootScope_) ->
    Projects = _Projects_
    $q = _$q_
    $rootScope = _$rootScope_

  beforeEach(module('TodoApp'))

  beforeEach(module(($provide) ->
    $provide.factory('$modal', () ->
      MockModal
    )

    return undefined
  ))

  beforeEach () ->
    inject(injectorFn)

    MockModal.open = () ->
      {
        result:
          $q.when({})
      }

  describe '.getProjects', () ->
    it 'expect to return projects', () ->
      expect(Projects.getProjects().length).to.equal(0)

  describe '.setProjects', () ->
    it 'expect to set comments', () ->
      Projects.setProjects(['first', 'second'])
      expect(Projects.getProjects().length).to.equal(2)

  describe '.newProjectModal', () ->
    it 'expect to add new project to projects', () ->
      Projects.newProjectModal()
      $rootScope.$digest()
      expect(Projects.getProjects().length).to.equal(1)

