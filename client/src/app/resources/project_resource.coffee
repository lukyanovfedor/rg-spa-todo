'use strict'

ProjectResourceFactory = ($resource) ->
  $resource('/projects/:id.json', { id: '@id'}, {
    update:
      method: 'PUT'
  })

angular
  .module('TodoApp')
  .factory('ProjectResource', [
    '$resource',
    ProjectResourceFactory
  ])
