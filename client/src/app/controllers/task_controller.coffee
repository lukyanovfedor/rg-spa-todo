'use strict'

class TaskController
  constructor: ($state, $scope, task, comments, Notifications, Template, Comments) ->
    @task = task
    @comments = comments

    @edit = () ->
      @task.isEdit = true

    @destroyCb = () =>
      Notifications.success(text: 'Task deleted.')
      $state.go('taskboard.projects')

    @updateCb = () =>
      Notifications.success(text: 'Task updated.')

    Comments.setComments(@comments)

    Template.setTitle(@task.title).setBodyClasses('single-task')

    $scope.$on('$destroy', () ->
      Comments.setComments([])
    )

angular
  .module('TodoApp')
  .controller('TaskController', [
    '$state',
    '$scope',
    'task',
    'comments',
    'Notifications',
    'Template',
    'Comments',
    TaskController
  ])
