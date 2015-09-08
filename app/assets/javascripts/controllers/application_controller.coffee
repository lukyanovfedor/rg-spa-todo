class ApplicationController
  constructor: ($rootScope, $scope, $auth, $state) ->
    goToAuth = () ->
      $state.go('auth')

    goToProjects = () ->
      $state.go('taskboard.projects')

    $rootScope.$on('auth:logout-success', goToAuth)

    $rootScope.$on('auth:login-success', goToProjects)
    $rootScope.$on('auth:registration-email-success', goToProjects)

    $rootScope.$on 'auth:validation-error', () ->
      console.log('auth:validation-error')

    $rootScope.$on 'auth:invalid', () ->
      console.log('auth:invalid')

angular
  .module('TodoApp')
  .controller('ApplicationController', [
    '$rootScope',
    '$scope',
    '$auth',
    '$state',
    ApplicationController
  ])