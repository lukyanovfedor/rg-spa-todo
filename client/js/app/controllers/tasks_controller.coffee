class TaskController
  constructor: (task, comments, CommentResource) ->
    @task = task
    @comments = comments

    @newComment = new CommentResource(task_id: @task.id, files: [])

    @formatCommentDate = (date) ->
      moment(date).format('h:mma MMMM Do YYYY')

    @destroyComment = (comment) ->
      comment
        .$delete()
        .then((comment) =>
          @comments = @comments.filter((c) -> c.id != comment.id)
        )

    @addNewComment = () ->
      return if @newCommentForm.$invalid

      @newComment
        .$create()
        .then((comment) =>
          @comments.push(comment)
          @newCommentForm.$setPristine()
          @newComment = new CommentResource(task_id: @task.id, files: [])
        )

angular
  .module('TodoApp')
  .controller('TaskController', [
    'task',
    'comments',
    'CommentResource',
    TaskController
  ])
