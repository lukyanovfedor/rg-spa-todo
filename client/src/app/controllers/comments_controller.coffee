'use strict'

class CommentsController
  constructor: (Comments, CommentResource, AttachmentResource, Notifications) ->
    @comments = Comments.getComments()
    @newComment = new CommentResource(attachments: [])

    @formatUpdated = (comment) ->
      moment(comment.updated_at).format('h:mma MMMM Do YYYY')

    @edit = (comment) ->
      if @cancel.original
        @cancel(false)

      @cancel.original = angular.copy(comment)

      comment.isEdit = true
      resetForm(comment)

    @cancel = (needToReset = true) ->
      if @cancel.original
        @cancel.original.attachments = @newComment.attachments.filter((a) -> !!a.id)
        angular.extend(@newComment, @cancel.original)
        @cancel.original = null

      @newComment.isEdit = false

      resetForm() if needToReset

    @destroy = (comment) ->
      Comments
        .destroy(comment)
        .then () ->
          Notifications.success(text: 'Comment deleted.')

    @submit = (task) ->
      return if @form.$invalid

      if @newComment.id
        update()
      else
        create(task)

    @removeAttachment = (attachment) =>
      if attachment.id
        AttachmentResource
          .delete(id: attachment.id)
          .$promise
          .then (response) =>
            Notifications.success(text: 'Attachment deleted.')
            @newComment.attachments = @newComment.attachments.filter (a) => a.id != response.id
      else
        index = @newComment.attachments.indexOf(attachment)
        @newComment.attachments.splice(index, 1) if index > -1

    update = () =>
      @newComment
        .$update()
        .then () ->
          Notifications.success(text: 'Comment updated.')
          resetForm()

    create = (task) =>
      @newComment.task_id = task.id

      Comments
        .create(@newComment)
        .then () =>
          Notifications.success(text: 'Comment created.')
          resetForm()

    resetForm = (comment) =>
      @form.$setPristine()

      if comment
        @newComment = comment
      else
        @newComment = new CommentResource(attachments: [])

angular
  .module('TodoApp')
  .controller('CommentsController', [
    'Comments',
    'CommentResource',
    'AttachmentResource',
    'Notifications',
    CommentsController
  ])
