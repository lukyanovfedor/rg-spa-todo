describe 'NewProjectModalController', () ->
  $scope = null
  $httpBackend = null

  MockModalInstance = {}

  injectorFn = (_$rootScope_, _$controller_, _$httpBackend_) ->
    $scope = _$rootScope_.$new()
    $httpBackend = _$httpBackend_

    _$controller_('NewProjectModalController as modalCtrl', { $scope: $scope })

  beforeEach(module('TodoApp'))

  beforeEach(module(($provide) ->
    $provide.factory('$modalInstance', () ->
      MockModalInstance
    )

    return undefined
  ))

  beforeEach(() ->
    simple.mock(MockModalInstance, 'dismiss')
    simple.mock(MockModalInstance, 'close')

    inject(injectorFn)
  )

  it 'expect to assigns a project', () ->
    expect($scope.modalCtrl.project).to.exist

  describe '.cancel', () ->
    it 'expect to assigns a function cancel', () ->
      expect($scope.modalCtrl.cancel).to.be.an.instanceof(Function)

    it 'expect to receive dismiss for $modalInstance', () ->
      $scope.modalCtrl.cancel()
      expect(MockModalInstance.dismiss.called).to.be.true

  describe '.submit', () ->
    beforeEach(() ->
      $scope.modalCtrl.form = {}
      $httpBackend.expectPOST('/projects.json').respond($scope.modalCtrl.project.toJSON())
    )

    it 'expect to assigns a function submit', () ->
      expect($scope.modalCtrl.submit).to.be.an.instanceof(Function)

    it 'expect to receive close for modalInstance, after save, when form valid', () ->
      $scope.modalCtrl.form.$invalid = false
      $scope.modalCtrl.submit()
      $httpBackend.flush()
      expect(MockModalInstance.close.called).to.be.true

    it 'expect to return, when form invalid', () ->
      $scope.modalCtrl.form.$invalid = true
      $scope.modalCtrl.submit()
      expect(MockModalInstance.close.called).not.to.be.true
