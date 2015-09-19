class ProjectController
  constructor: (project, tasks, $state, TaskResource) ->
    @project = project

    @projectDestroyCallback = () ->
      $state.go('taskboard.projects')

    @newTask = new TaskResource()
    @addNewTask = () ->
      return if @newTaskForm.$invalid

      @newTask
        .$save(projectId: @project.id)
        .then(() =>
          @newTaskForm.$setPristine()
          @newTask = new TasksResource()
        )

angular
.module('TodoApp')
.controller('ProjectController', [
    'project',
    'tasks',
    '$state',
    'TaskResource',
    ProjectController
  ])