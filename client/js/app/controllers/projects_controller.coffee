class ProjectsController
  constructor: (projects, $scope) ->
    @projects = projects || []

    @projectDestroyCallback = () =>
      @projects = @projects.filter((p) -> !!p.id)

angular
  .module('TodoApp')
  .controller('ProjectsController', [
    'projects',
    '$scope',
    ProjectsController
  ])
