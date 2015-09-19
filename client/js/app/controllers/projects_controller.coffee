class ProjectsController
  constructor: (projects, $scope) ->
    @projects = projects || []

    @projectDestroyCallback = (project) =>
      @projects = @projects.filter((p) -> !!p.id)

angular
  .module('TodoApp')
  .controller('ProjectsController', [
    'projects',
    '$scope',
    ProjectsController
  ])
