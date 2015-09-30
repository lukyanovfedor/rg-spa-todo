'use strict'

class HeaderController
  constructor: ($rootScope, $auth, $state, Projects, Notifications) ->
    @user = $rootScope.user

    @signOut = () ->
      $auth.signOut()

    @createProject = () ->
      Projects
        .newProjectModal()
        .then () ->
          Notifications.success(text: 'Project created.')
          unless $state.is('taskboard.projects')
            $state.go('taskboard.projects')

angular
  .module('TodoApp')
  .controller('HeaderController', [
    '$rootScope',
    '$auth',
    '$state',
    'Projects',
    'Notifications',
    HeaderController
  ])