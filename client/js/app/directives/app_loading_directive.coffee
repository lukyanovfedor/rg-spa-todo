angular
  .module('TodoApp')
  .directive('appLoading', ['$animate', ($animate) ->
    {
      restrict: 'C',
      link: (scope, element, attrs) ->
        removePreloader = () ->
          $animate
            .leave(element.children())
            .then(() ->
              element.remove()
              scope = element = attrs = null
            )

#        setTimeout(removePreloader, 0)
        removePreloader()
    }
  ])
