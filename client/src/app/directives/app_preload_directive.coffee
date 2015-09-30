'use strict'

AppPreloadDirective = ($animate, $timeout) ->
  link = (scope, el, attrs) ->
    removePreloader = () ->
      $animate
        .leave(el.children())
        .then () ->
          el.remove()
          scope = el = attrs = null


#    $timeout(removePreloader, 0)
    removePreloader()

  {
    restrict: 'A'
    link: link
  }

angular
  .module('TodoApp')
  .directive('appPreload', [
    '$animate',
    '$timeout',
    AppPreloadDirective
  ])
