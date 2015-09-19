class AuthController
  constructor: (Template, $auth) ->
    Template.setTitle('Welcome')
    Template.setBodyClasses('auth')

    @registerData = {}
    @register = $auth.submitRegistration.bind($auth, @registerData)

    @loginData = {}
    @login = $auth.submitLogin.bind($auth, @loginData)

angular
  .module('TodoApp')
  .controller('AuthController', [
    'Template',
    '$auth',
    AuthController
  ])
