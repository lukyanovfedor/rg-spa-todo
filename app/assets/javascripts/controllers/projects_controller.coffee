class ProjectsController
  constructor: (ProjectResource, $scope) ->
    @projects = ProjectResource.query()

    @projectDestroyCallback = (project) =>
      @projects = @projects.filter((p) -> !!p.id)

angular
  .module('TodoApp')
  .controller('ProjectsController', [
    'ProjectResource',
    '$scope',
    ProjectsController
  ])
