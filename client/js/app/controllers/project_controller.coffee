class ProjectController
  constructor: (project, tasks, $state, TaskResource) ->
    @project = project
    @tasks = tasks

    @formatTaskDate = (date) ->
      moment(date).format('DD MMM YY')

    @taskExpired = (date) ->
      parseInt(moment(date).valueOf(), 10) < parseInt(moment().startOf('day').valueOf(), 10)

    @toggleTask = (task) ->
      task.$toggle()

    @projectDestroyCallback = () ->
      $state.go('taskboard.projects')

    @taskDestroyCallback = () =>
      @tasks = @tasks.filter((t) => !!t.id)

    @newTask = new TaskResource(project_id: @project.id)

    @addNewTask = () ->
      return if @newTaskForm.$invalid

      @newTask
        .$create()
        .then((task) =>
          @tasks.push(task)
          @newTaskForm.$setPristine()
          @newTask = new TaskResource(project_id: @project.id)
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