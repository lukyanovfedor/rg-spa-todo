angular
.module('TodoApp')
.factory('CsrfInterceptor', [()->
    Interceptor = {}

    header =
      name: 'X-CSRF-Token'
      value: 'csrf-token'

    try
      header.value = document.querySelector('meta[name="csrf-token"]').content
    catch
      console.warn('Unable to get csrf token')

    Interceptor.request = (config) ->
      return config if config.method == 'GET'

      config.headers = config.headers || {}
      config.headers[header.name] = header.value

      return config

    return Interceptor
  ])