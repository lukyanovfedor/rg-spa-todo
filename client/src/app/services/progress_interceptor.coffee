'use strict'

ProgressInterceptor = (ngProgressFactory, $q) ->
  Interceptor = {}

  progress = null
  templateUrlPattern = /^templates?\//

  Interceptor.request = (config) ->
    return config if templateUrlPattern.test(config.url)

    progress ?= ngProgressFactory.createInstance()
    progress.setColor('#678cf3')
    progress.start()

    config

  Interceptor.response = (response) ->
    return response if templateUrlPattern.test(response.config.url)

    progress.complete()

    response

  Interceptor.requestError = (err) ->
    progress.complete()
    $q.reject(err)

  Interceptor.responseError = (err) ->
    progress.complete()
    $q.reject(err)

  Interceptor

angular
  .module('TodoApp')
  .factory('ProgressInterceptor', [
    'ngProgressFactory',
    '$q',
    ProgressInterceptor
  ])
