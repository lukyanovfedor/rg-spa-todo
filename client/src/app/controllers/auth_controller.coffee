'use strict'

class AuthController
  constructor: ($auth, $scope, Template) ->
    @registerData = {}
    @register = () ->
      return if @regForm.$invalid
      $auth.submitRegistration(@registerData)

    @loginData = {}
    @login = () ->
      return if @loginForm.$invalid
      $auth.submitLogin(@loginData)

    @facebook = () ->
      $auth.authenticate('facebook')

    Template.setTitle('Welcome').setBodyClasses('auth')

angular
  .module('TodoApp')
  .controller('AuthController', [
    '$auth',
    '$scope',
    'Template',
    AuthController
  ])
