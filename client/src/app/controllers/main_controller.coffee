'use strict'

class MainController
  constructor: ($rootScope, $auth, $state, Template, Notifications) ->
    @Template = Template

    @notifications = Notifications.getCurrent()
    @removeNotification = (notification) -> Notifications.remove(notification)

    goToAuth = () -> $state.go('auth')
    goToProjects = () -> $state.go('taskboard.projects')

    $rootScope.$on('auth:logout-success', goToAuth)
    $rootScope.$on('auth:validation-error', goToAuth)
    $rootScope.$on('auth:invalid', goToAuth)

    $rootScope.$on('auth:login-success', goToProjects)
    $rootScope.$on('auth:registration-email-success', goToProjects)

angular
  .module('TodoApp')
  .controller('MainController', [
    '$rootScope',
    '$auth',
    '$state',
    'Template',
    'Notifications'
    MainController
  ])