'use strict'

CommentResourceFactory = ($resource) ->
  cleanResourceAttributes = (data) ->
    cleanData = {}
    pattern = /^\$.+|toJSON$/

    for key, value of data
      cleanData[key] = data[key] unless pattern.test(key)

    cleanData

  createFormData = (data) ->
    formData = new FormData()

    for key, value of data
      if key == 'attachments'
        name = 'comment[attachments_attributes][][file]'
        data.attachments.forEach (file) ->
          formData.append(name, file, file.name) if file instanceof File
      else
        formData.append("comment[#{key}]", value)

    formData

  $resource('/comments/:id.json', { id: '@id' }, {
    update:
      method: 'PUT'
      headers:
        'Content-Type': undefined
      transformRequest: [cleanResourceAttributes, createFormData]
    query:
      url: '/tasks/:taskId/comments.json'
      isArray: true
      params:
        taskId: '@task_id'
    create:
      url: '/tasks/:taskId/comments.json'
      method: 'POST'
      params:
        taskId: '@task_id'
      headers:
        'Content-Type': undefined
      transformRequest: [cleanResourceAttributes, createFormData]
  })

angular
  .module('TodoApp')
  .factory('CommentResource', [
    '$resource',
    CommentResourceFactory
  ])