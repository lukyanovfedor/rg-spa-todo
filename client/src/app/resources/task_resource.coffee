'use strict'

TaskResourceFactory = ($resource) ->
  convertDeadlineFormat = (data) ->
    if (data.deadline)
      data.deadline = moment(data.deadline).format('DD-MM-YYYY')

    angular.toJson(data)

  $resource('/tasks/:id/:action.json', { id: '@id' }, {
      update:
        method: 'PUT'
        transformRequest: [convertDeadlineFormat]
      toggle:
        method: 'PUT'
        params:
          action: 'toggle'
      sort:
        method: 'PUT'
        params:
          action: 'sort'
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
        transformRequest: [convertDeadlineFormat]
    })

angular
  .module('TodoApp')
  .factory('TaskResource', [
    '$resource',
    TaskResourceFactory
  ])
