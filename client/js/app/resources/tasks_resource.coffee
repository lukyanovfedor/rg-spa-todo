angular
.module('TodoApp')
.factory('TaskResource', ['$resource', ($resource) ->
    $resource('/projects/:projectId/tasks/:id.json', { id: '@id'}, {
      update:
        method: 'PUT'
    })
  ])