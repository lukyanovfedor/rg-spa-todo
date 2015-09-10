angular
  .module('TodoApp')
  .factory('ProjectResource', ['$resource', ($resource) ->
    $resource('/projects/:id.json', { id: '@id'}, {
      update:
        method: 'PUT'
    })
  ])