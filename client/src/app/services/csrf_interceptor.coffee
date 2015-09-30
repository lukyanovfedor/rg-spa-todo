'use strict'

CsrfInterceptor = () ->
  Interceptor = {}

  header =
    name: 'X-CSRF-Token'
    value: 'csrf-token'

  try
    header.value = document.querySelector('meta[name="csrf-token"]').content

  Interceptor.request = (config) ->
    return config if config.method == 'GET'

    config.headers = config.headers || {}
    config.headers[header.name] = header.value

    config

  Interceptor

angular
  .module('TodoApp')
  .factory('CsrfInterceptor', [
    CsrfInterceptor
  ])
