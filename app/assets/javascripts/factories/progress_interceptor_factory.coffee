angular
  .module('TodoApp')
  .factory('ProgressInterceptorFactory', ['ngProgressFactory', (ngProgressFactory)->
    Interceptor = {}

    progress = null

    complete = () ->
      progress.complete()
      progress = null

    Interceptor.request = (config) ->
      progress = progress || ngProgressFactory.createInstance()
      progress.setColor('#678cf3')
      progress.start()

      return config

    Interceptor.response = (response) ->
      complete() if progress
      return response

    Interceptor.requestError = (err) ->
      complete() if progress
      return err

    Interceptor.responseError = (err) ->
      complete() if progress
      return err

    return Interceptor
  ])