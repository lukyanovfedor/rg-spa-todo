hasErrorsDirective = () ->

  valid = (field, form) ->
    !(form[field].$invalid && (form[field].$dirty || form.$submitted))

  link = (scope, el) ->
    input = el[0].querySelector('input, textarea')
    return if input.type && input.type == 'submit'

    handler = (event) ->
      if valid(scope.field, scope.form)
        el.removeClass('has-error')
      else
        el.addClass('has-error')

    input.addEventListener('input', handler, false)

    scope.$on('$destroy', () ->
      input.removeEventListener('input', handler, false)
    )

  return {
    restrict: 'A'
    scope:
      field: '@field'
      form: '=form'
    link: link
  }

angular
  .module('TodoApp')
  .directive('hasErrors', [hasErrorsDirective])