EditableDirective = () ->
  lastScope = null

  link = (scope, el)  ->
    scope.hasDeadline = scope.model.hasOwnProperty('deadline')

    scope.original =
      title: scope.model.title
      deadline: scope.model.deadline

    scope.needToUpdate = () ->
      titleChanged = scope.model.title != scope.original.title
      deadlineChanged = scope.model.deadline != scope.original.deadline

      titleChanged || deadlineChanged

    scope.cancel = (setOldValues = true) ->
      if setOldValues
        scope.model.title = scope.original.title
        scope.model.deadline = scope.original.deadline if scope.hasDeadline

      lastScope = null

      scope.model.isEdit = false

    scope.finish = (form) ->
      return if form.$invalid
      return scope.cancel() unless scope.needToUpdate()

      scope
        .model
        .$update()
        .then(scope.cancel.bind(scope, false))

    scope.delete = () ->
      scope
        .model
        .$delete()
        .then(() =>
          scope.cancel()
          scope.destroyCb(scope.model) if scope.destroyCb
        )

    keyUpHandler = (event) ->
      if event.keyCode && event.keyCode == 27
        scope.$apply(scope.cancel)

    # directive init
    lastScope.cancel() if lastScope
    lastScope = scope

    el[0].querySelector('input').focus()

    document.addEventListener('keyup', keyUpHandler)
    scope.$on('$destroy', () ->
      document.removeEventListener('keyup', keyUpHandler)
    )

  return {
    restrict: 'E'
    templateUrl: 'directives/editable.html'
    replace: true
    scope:
      model: '='
      destroyCb: '='
    link: link
  }

angular
  .module('TodoApp')
  .directive('editable', [EditableDirective])