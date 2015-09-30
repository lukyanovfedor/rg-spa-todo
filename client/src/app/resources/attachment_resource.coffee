'use strict'

AttachmentResourceFactory = ($resource) ->
  $resource('/attachments/:id.json', { id: '@id' })

angular
  .module('TodoApp')
  .factory('AttachmentResource', [
    '$resource',
    AttachmentResourceFactory
  ])
