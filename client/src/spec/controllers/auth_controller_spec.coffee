describe 'AuthController', () ->
  $scope = null
  MockTemplate = {}
  MockAuth = {}

  injectorFn = (_$rootScope_, _$controller_) ->
    $scope = _$rootScope_.$new()

    _$controller_('AuthController as authCtrl', { $scope: $scope })

  beforeEach(module('TodoApp'))

  beforeEach(module(($provide) ->
    $provide.factory('Template', () ->
      MockTemplate
    )

    $provide.provider('$auth', () ->
      return {
        configure: () ->
        $get: () ->
          MockAuth
      }
    )

    return undefined
  ))

  beforeEach(() ->
    simple.mock(MockTemplate, 'setTitle').returnWith(MockTemplate)
    simple.mock(MockTemplate, 'setBodyClasses').returnWith(MockTemplate)

    simple.mock(MockAuth, 'initialize')
    simple.mock(MockAuth, 'submitRegistration')
    simple.mock(MockAuth, 'submitLogin')

    inject(injectorFn)
  )

  it 'expect to assigns a register data', () ->
    expect($scope.authCtrl.registerData).to.be.an.instanceOf(Object)

  it 'expect to assigns a login data', () ->
    expect($scope.authCtrl.loginData).to.be.an.instanceOf(Object)

  it 'expect to receive setTitle', () ->
    expect(MockTemplate.setTitle.called).to.be.true

  it 'expect to receive setBodyClasses', () ->
    expect(MockTemplate.setBodyClasses.called).to.be.true

  describe '.register', () ->
    it 'expect to assigns a register', () ->
      expect($scope.authCtrl.register).to.be.an.instanceOf(Function)

    describe 'form valid', () ->
      it 'expect to receive submitRegistration', () ->
        $scope.authCtrl.regForm = {}
        $scope.authCtrl.register()
        expect(MockAuth.submitRegistration.called).to.be.true

    describe 'form invalid', () ->
      it 'expect not to receive submitRegistration', () ->
        $scope.authCtrl.regForm = {$invalid: true}
        $scope.authCtrl.register()
        expect(MockAuth.submitRegistration.called).to.be.false

  describe '.login', () ->
    it 'expect to assigns a login', () ->
      expect($scope.authCtrl.login).to.be.an.instanceOf(Function)

    describe 'form valid', () ->
      it 'expect to receive submitLogin', () ->
        $scope.authCtrl.loginForm = {}
        $scope.authCtrl.login()
        expect(MockAuth.submitLogin.called).to.be.true

    describe 'form invalid', () ->
      it 'expect not to receive submitLogin', () ->
        $scope.authCtrl.loginForm = {$invalid: true}
        $scope.authCtrl.login()
        expect(MockAuth.submitLogin.called).to.be.false
