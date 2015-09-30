'use strict'

HasErrorsDirective = () ->
  link = (scope, el, attrs, form) ->
    watchValue = () ->
      form[scope.field].$invalid && (form[scope.field].$dirty || form.$submitted)

    handler = (newValue) ->
      if newValue
        el.addClass('has-error')
      else
        el.removeClass('has-error')

    removeWatch = scope.$watch(watchValue, handler)

    scope.$on('$destroy', () -> removeWatch())

  {
    restrict: 'A'
    link: link
    require : '^form'
    scope:
      field: '@hasErrors'
  }

angular
  .module('TodoApp')
  .directive('hasErrors', [
    HasErrorsDirective
  ])
