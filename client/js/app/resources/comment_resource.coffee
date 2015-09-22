angular
  .module('TodoApp')
  .factory('CommentResource', ['$resource', ($resource) ->
      $resource('/comments/:id.json', { id: '@id' }, {
        update:
          method: 'PUT'
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
            enctype: 'multipart/form-data'
          transformRequest: (data) ->
            formData = new FormData()

            for key, value of data
              if key == 'files'
                data.files.forEach((file) ->
                  formData.append("comment[files][]", file, file.name)
                )
              else
                formData.append("comment[#{key}]", value)

            formData
      })
    ])