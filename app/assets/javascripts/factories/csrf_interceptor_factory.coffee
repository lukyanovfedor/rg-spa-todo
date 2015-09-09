Interceptor = {}

param =
  name: 'csrf-param'
  value: 'csrf-token'

try
  param.name = document.querySelector('meta[name="csrf-param"]').content
  param.value = document.querySelector('meta[name="csrf-token"]').content
catch
  console.warn('Unable to get csrf token')

Interceptor.request = (config) ->
  return config if config.method == 'GET'

  config.data[param.name] = param.value

  return config

angular
.module('TodoApp')
.factory('CsrfInterceptorFactory', [()->
    return Interceptor
  ])