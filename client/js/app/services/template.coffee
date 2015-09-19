angular
  .module('TodoApp')
  .factory('Template', [() ->
    return {
      _title: ''
      _bodyClasses: ''

      getTitle: () ->
        unless @_title
          return 'Todo'

        "#{@_title} - Todo"

      setTitle: (title) ->
        @_title = title

      getBodyClasses: () ->
        return @_bodyClasses

      setBodyClasses: (bodyClasses) ->
        @_bodyClasses = bodyClasses
    }
  ])