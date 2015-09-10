lastScope = null

angular
  .module('TodoApp')
  .directive('projectTitle', [() ->
    return {
      restrict: 'E'
      templateUrl: 'directives/project_title.html'
      replace: true
      scope:
        project: '=project'
        destroyCb: '=destroyCb'
      link: (scope, el, attrs, ctrl) ->
        keyUpHandler = (event) ->
          if event.keyCode && event.keyCode == 27 && scope.isEdit
            scope.$apply(scope.cancelEdit)

        scope.isEdit = false
        scope.oldTitle = ''

        scope.startEdit = () ->
          if lastScope
            lastScope.cancelEdit()

          document.addEventListener('keyup', keyUpHandler)

          lastScope = scope

          scope.oldTitle = scope.project.title
          scope.isEdit = true
          setTimeout(() -> el[0].querySelector('input').focus())

        scope.cancelEdit = (setOldTitle = true) ->
          document.removeEventListener('keyup', keyUpHandler)

          lastScope = null

          scope.project.title = scope.oldTitle if setOldTitle

          scope.oldTitle = ''
          scope.isEdit = false

        scope.finishEdit = (form) ->
          return if form.$invalid
          return scope.cancelEdit() if scope.oldTitle == scope.project.title

          scope
            .project
            .$update()
            .then(scope.cancelEdit.bind(scope, false))

        scope.deleteProject = () ->
          scope
            .project
            .$delete()
            .then(() =>
              scope.destroyCb(scope.project) if scope.destroyCb
              scope.cancelEdit()
            )

        scope.$on('$destroy', () ->
          document.removeEventListener('keyup', keyUpHandler)
        )
    }
  ])