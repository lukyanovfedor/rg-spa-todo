'use strict'

class NewProjectModalController
  constructor: ($modalInstance, ProjectResource) ->
    @project = new ProjectResource(title: 'New project')

    @cancel = () ->
      $modalInstance.dismiss()

    @submit = () ->
      return if @form.$invalid

      @project
        .$save()
        .then () =>
          $modalInstance.close(@project)

angular
  .module('TodoApp')
  .controller('NewProjectModalController', [
    '$modalInstance',
    'ProjectResource',
    NewProjectModalController
  ])