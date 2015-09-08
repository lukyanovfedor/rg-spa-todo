class AuthController
  constructor: ($auth) ->
    @registerData = {}
    @register = $auth.submitRegistration.bind($auth, @registerData)

    @loginData = {}
    @login = $auth.submitLogin.bind($auth, @loginData)

angular
  .module('TodoApp')
  .controller('AuthController', [
    '$auth',
    AuthController
  ])
