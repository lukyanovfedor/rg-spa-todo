showErrorsDirective = (ValidationErrors) ->

  link = (scope, el) ->
    scope.errors = {}

    scope.messages = ValidationErrors

    scope.unValid = () ->
      scope.form[scope.field].$invalid &&
        (scope.form[scope.field].$dirty || scope.form.$submitted)

    watchFunk = (newVal) ->
      scope.errors = newVal

    watchValue = (scope) ->
      scope.form[scope.field].$error

    unwatch = scope.$watch(watchValue, watchFunk, true)

    scope.$on('$destroy', () -> unwatch())

  return {
    restrict: 'E'
    replace: true
    templateUrl: 'directives/show_errors.html'
    scope:
      field: '@field'
      form: '=form'
    link: link
  }

angular
.module('TodoApp')
.directive('showErrors', [
  'ValidationErrors',
  showErrorsDirective
])