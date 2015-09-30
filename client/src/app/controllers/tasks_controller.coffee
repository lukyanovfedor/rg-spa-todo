'use strict'

class TasksController
  constructor: (TaskResource, Notifications) ->
    @newTask = new TaskResource()

    @formatDeadline = (task) ->
      moment(task.deadline).format('DD MMM YY')

    @isExpired = (task) ->
      moment(task.deadline).valueOf() < moment().startOf('day').valueOf()

    @toggle = (task) ->
      TaskResource
        .toggle(id: task.id)
        .$promise
        .then (response) =>
          task.state = response.state

    @createTask = (project) ->
      return if @form.$invalid

      @newTask.project_id = project.id

      @newTask
        .$create()
        .then (task) =>
          @form.$setPristine()
          @newTask = new TaskResource()
          project.tasks.push(task)
          Notifications.success(text: 'Task created.')

    @dragAndDropCb =
      orderChanged: (event) =>
        task = event.dest.sortableScope.modelValue[event.dest.index]

        TaskResource
          .update({ id: task.id }, { position: event.dest.index + 1 })
          .$promise
          .then (response) =>
            task.position = response.position

angular
  .module('TodoApp')
  .controller('TasksController', [
    'TaskResource',
    'Notifications',
    TasksController
  ])
