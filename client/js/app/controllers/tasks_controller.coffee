class TaskController
  constructor: (task) ->
    @task = task

angular
  .module('TodoApp')
  .controller('TaskController', [
    'task',
    TaskController
  ])
