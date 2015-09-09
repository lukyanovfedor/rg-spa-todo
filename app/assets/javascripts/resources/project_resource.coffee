angular
  .module('TodoApp')
  .factory('ProjectResource', ['$resource', ($resource) ->
    $resource('/projects/:id.json', { id: '@id'}, {
      list: {
        method: 'GET',
        isArray: true
      }
    })
  ])