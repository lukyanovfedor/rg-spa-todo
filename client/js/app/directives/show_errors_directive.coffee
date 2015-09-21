showErrorsDirective = () ->
  return {
    restrict: 'E'
    replace: true
    require: '^form'
    template: [
      '<div ng-if="form.$dirty" class="validation-errors">',
        '<form-errors errors-tmpl="directives/show_errors.html"></form-errors>',
      '</div>'
    ].join('')
    link: (scope, el, attrs, form) ->
      scope.form = form
  }

angular
  .module('TodoApp')
  .directive('showErrors', [showErrorsDirective])