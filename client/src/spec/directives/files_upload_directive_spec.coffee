describe 'appPreload', () ->
  element = null
  isolated = null
  $scope = null

  injectFn = (_$rootScope_, _$compile_) ->
    $scope = _$rootScope_.$new()
    $scope.model = []

    element = '<div files-upload="model"></div>'
    element = _$compile_(element)($scope)

    $scope.$digest()

    isolated = element.isolateScope()

  beforeEach(module('TodoApp'))

  beforeEach () ->
    inject(injectFn)

  describe '.addFiles', () ->
    it 'expect to add files into model', () ->
      isolated.addFiles(['first', 'second'])
      expect($scope.model.length).to.equal(2)

  describe 'droparea events', () ->
    droparea = null

    beforeEach () ->
      droparea = element.find('div')

    it 'expect to add class dragover to el on dragover', () ->
      droparea.triggerHandler('dragover')
      expect(element.hasClass('dragover')).to.be.true

    it 'expect to remove class dragover from el on dragleave', () ->
      droparea.triggerHandler('dragover')
      droparea.triggerHandler('dragleave')
      expect(element.hasClass('dragover')).to.be.false

    it 'expect to call addFiles on drop', () ->
      simple.mock(isolated, 'addFiles')
      droparea.triggerHandler(type: 'drop', dataTransfer: { files: ['file'] })
      expect(isolated.addFiles.called).to.be.true

  describe 'input events', () ->
    input = null

    beforeEach () ->
      input = element.find('input')

    it 'expect to call addFiles on change', () ->
      simple.mock(isolated, 'addFiles')
      input.triggerHandler(type: 'change', target: { files: ['file'] })
      expect(isolated.addFiles.called).to.be.true


