class ProjectModalController
  constructor: ($modalInstance, ProjectResource) ->
    @project = new ProjectResource(title: 'New project')

    @cancel = $modalInstance.dismiss.bind($modalInstance)

    @create = () ->
      return if @projectNew.$invalid

      @project
        .$save()
        .then($modalInstance.close.bind($modalInstance, @project))
        .catch(@cancel)

angular
  .module('TodoApp')
  .controller('ProjectModalController', [
    '$modalInstance',
    'ProjectResource',
    ProjectModalController
  ])