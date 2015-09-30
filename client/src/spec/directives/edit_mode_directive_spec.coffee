describe 'editMode', () ->
  element = null
  $scope = null
  $compile = null

  injectFn = (_$rootScope_, _$compile_, _$q_) ->
    $scope = _$rootScope_.$new()
    $compile = _$compile_

    simple.Promise = _$q_

  compileDirective = () ->
    element = '<edit-mode model="model" destroy-cb="destroyCb" update-cb="updateCb"></edit-mode>'
    element = $compile(element)($scope)
    $scope.$digest()

  beforeEach(module('TodoApp'))

  beforeEach(module(($provide) ->

    return undefined
  ))

  beforeEach () ->
    inject(injectFn)

  describe '.hasDeadline', () ->
    it 'expect to assign hasDeadline true, if model has property deadline', () ->
      $scope.model = { deadline: 'some deadline' }
      compileDirective()
      expect(element.isolateScope().hasDeadline).to.be.true

    it 'expect to assign hasDeadline false, if model has not property deadline', () ->
      $scope.model = {}
      compileDirective()
      expect(element.isolateScope().hasDeadline).to.be.false

  describe '.original', () ->
    beforeEach () ->
      $scope.model = { title: 'some title', deadline: 'some deadline' }
      compileDirective()

    it 'expect to assign original object', () ->
      expect(element.isolateScope().original).to.be.an.instanceof(Object)

    it 'expect to assign title in original object, with model title', () ->
      expect(element.isolateScope().original.title).to.be.equal('some title')

    it 'expect to assign deadline in original object, with model deadline', () ->
      expect(element.isolateScope().original.deadline).to.be.equal('some deadline')

  describe '.needToUpdate', () ->
    beforeEach () ->
      $scope.model = { title: 'some title', deadline: 'some deadline' }
      compileDirective()

    it 'expect to return true if model title changed', () ->
      $scope.model.title = 'yo'
      expect(element.isolateScope().needToUpdate()).to.be.true

    it 'expect to return true if model deadline changed', () ->
      $scope.model.deadline = 'yo'
      expect(element.isolateScope().needToUpdate()).to.be.true

    it 'expect to return false if model did not chang', () ->
      expect(element.isolateScope().needToUpdate()).to.be.false

  describe '.cancel', () ->
    beforeEach () ->
      $scope.model = { title: 'some title', deadline: 'some deadline' }
      compileDirective()

    it 'expect to set model isEdit to false', () ->
      element.isolateScope().cancel()
      expect(element.isolateScope().model.isEdit).to.be.false

    it 'expect to set model title to original if called with true argument', () ->
      $scope.model.title = 'yo'
      element.isolateScope().cancel(true)
      expect(element.isolateScope().model.title).to.equal('some title')

    it 'expect to set model deadline to original if called with true argument', () ->
      $scope.model.deadline = 'yo'
      element.isolateScope().cancel(true)
      expect(element.isolateScope().model.deadline).to.equal('some deadline')

  describe '.destroy', () ->
    beforeEach () ->
      $scope.model = {}
      simple.mock($scope, 'destroyCb')
      simple.mock($scope.model, '$delete').resolveWith({})
      compileDirective()

    it 'expect to receive $delete for model', () ->
      element.isolateScope().destroy()
      expect($scope.model.$delete.called).to.be.true

    it 'expect to call cancel', () ->
      isolated = element.isolateScope()
      simple.mock(isolated, 'cancel')
      isolated.destroy()
      $scope.$digest()
      expect(isolated.cancel.called).to.be.true

    it 'expect to call $scope.destroyCb, if provided', () ->
      element.isolateScope().destroy()
      $scope.$digest()
      expect($scope.destroyCb.called).to.be.true

  describe '.update', () ->
    isolated = null

    beforeEach () ->
      $scope.model = {}
      simple.mock($scope, 'updateCb')
      simple.mock($scope.model, '$update').resolveWith({})
      compileDirective()
      isolated = element.isolateScope()

    it 'expect to receive cancel, if needToUpdate return false', () ->
      simple.mock(isolated, 'needToUpdate').returnWith(false)
      simple.mock(isolated, 'cancel')
      isolated.update({})
      expect(isolated.cancel.called).to.be.true

    it 'expect to receive update for model', () ->
      simple.mock(isolated, 'needToUpdate').returnWith(true)
      isolated.update({})
      expect(isolated.model.$update.called).to.be.true

    it 'expect to call $scope.updateCb, if provided', () ->
      simple.mock(isolated, 'needToUpdate').returnWith(true)
      isolated.update({})
      $scope.$digest()
      expect($scope.updateCb.called).to.be.true
