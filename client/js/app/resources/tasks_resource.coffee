angular
  .module('TodoApp')
  .factory('TaskResource', ['$resource', ($resource) ->
    $resource('/tasks/:id/:action.json', { id: '@id' }, {
      update:
        method: 'PUT'
        transformRequest: [(data) ->
          if (data.deadline)
            data.deadline = moment(data.deadline).format('DD-MM-YYYY')

          angular.toJson(data)
        ]
      toggle:
        method: 'PUT'
        params:
          action: 'toggle'
      query:
        url: '/projects/:projectId/tasks.json'
        isArray: true
        params:
          projectId: '@project_id'
      create:
        url: '/projects/:projectId/tasks.json'
        method: 'POST'
        params:
          projectId: '@project_id'
        transformRequest: [(data) ->
          if (data.deadline)
            data.deadline = moment(data.deadline).format('DD-MM-YYYY')

          angular.toJson(data)
        ]
    })
  ])