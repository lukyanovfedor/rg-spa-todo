class ProjectsController
  constructor: (ProjectResource, $scope) ->
    @projects = ProjectResource.list()

    $scope.$on('projects:new_project', (ev, project) =>
      @projects.push(project)
    )

angular
  .module('TodoApp')
  .controller('ProjectsController', [
    'ProjectResource',
    '$scope',
    ProjectsController
  ])
