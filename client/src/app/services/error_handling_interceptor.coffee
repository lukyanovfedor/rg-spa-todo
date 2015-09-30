'use strict'

ErrorHandlingInterceptor = ($q, Notifications) ->
  Interceptor = {}

  Interceptor.responseError = (err) ->
    if err.data.messages && err.data.messages.length
      err.data.messages.forEach (m) ->
        Notifications.error(text: m)
    else if err.data.details
      Notifications.error(text: err.data.details)
    else if err.data.errors && err.data.errors.length
      err.data.errors.forEach (e) ->
        Notifications.error(text: e)
    else if err.data.errors && err.data.errors.full_messages
      err.data.errors.full_messages.forEach (e) ->
        Notifications.error(text: e)
    else
      Notifications.error()

    $q.reject(err)

  Interceptor

angular
  .module('TodoApp')
  .factory('ErrorHandlingInterceptor', [
    '$q',
    'Notifications',
    ErrorHandlingInterceptor
  ])
