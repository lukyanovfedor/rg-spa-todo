'use strict'

EditModeDirective = () ->
  lastScope = null

  ctrl = ($scope) ->
    $scope.hasDeadline = $scope.model.hasOwnProperty('deadline')

    $scope.original =
      title: $scope.model.title
      deadline: $scope.model.deadline

    $scope.needToUpdate = () ->
      titleChanged = $scope.model.title != $scope.original.title
      deadlineChanged = $scope.model.deadline != $scope.original.deadline

      titleChanged || deadlineChanged

    $scope.cancel = (setOldValues = true) ->
      if setOldValues
        $scope.model.title = $scope.original.title
        $scope.model.deadline = $scope.original.deadline if $scope.hasDeadline

      lastScope = null
      $scope.model.isEdit = false

    $scope.update = (form) ->
      return if form.$invalid
      return $scope.cancel() unless $scope.needToUpdate()

      $scope
        .model
        .$update()
        .then () =>
          $scope.cancel(false)
          $scope.updateCb($scope.model) if $scope.updateCb

    $scope.destroy = () ->
      $scope
        .model
        .$delete()
        .then () =>
          $scope.cancel()
          $scope.destroyCb($scope.model) if $scope.destroyCb


  link = (scope, el)  ->
    keyUpHandler = (event) ->
      if event.keyCode && event.keyCode == 27
        scope.$apply(scope.cancel)

    lastScope.cancel() if lastScope
    lastScope = scope

    el[0].querySelector('input').focus()

    document.addEventListener('keyup', keyUpHandler)
    scope.$on('$destroy', () ->
      document.removeEventListener('keyup', keyUpHandler)
    )

  return {
    restrict: 'E'
    templateUrl: 'templates/directives/edit_mode.html'
    replace: true
    scope:
      model: '='
      destroyCb: '='
      updateCb: '='
    controller: ['$scope', ctrl]
    link: link
  }

angular
  .module('TodoApp')
  .directive('editMode', [
    EditModeDirective
  ])
