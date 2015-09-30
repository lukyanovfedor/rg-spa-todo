'use strict'

ProjectsFactory = ($q, $modal, $rootScope) ->
  Factory = {}

  projects = null

  Factory.getProjects = () ->
    projects || []

  Factory.setProjects = (data) ->
    projects = data

  Factory.newProjectModal = () ->
    deferred = $q.defer()

    $modal
      .open(
        templateUrl: 'templates/modals/new_project.html',
        controller: 'NewProjectModalController'
        controllerAs: 'modalCtrl'
      )
      .result
      .then (project) ->
        Factory.setProjects([]) unless projects
        projects.push(project)

        deferred.resolve(project)
      .catch (err) ->
        deferred.reject(err)

    deferred.promise

  Factory

angular
  .module('TodoApp')
  .factory('Projects', [
    '$q',
    '$modal',
    '$rootScope',
    ProjectsFactory
  ])
