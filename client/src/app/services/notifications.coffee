'use strict'

NotificationsFactory = ($timeout) ->
  Notifications = {}

  defaults =
    limit: 4
    success:
      title: 'Success'
      text: 'Action performed successfully.'
      time: 3000
    error:
      title: 'Error'
      text: 'Oops, something went wrong.'
      time: 3000

  current = []
  queue = []

  add = (opt) ->
    return queue.push(opt) if current.length >= defaults.limit

    notification = angular.extend({}, defaults[opt.type], opt)

    current.push(notification)
    notification.timeout = $timeout(remove.bind(null, notification), notification.time)

  remove = (notification) ->
    return unless notification

    index = current.indexOf(notification)

    $timeout.cancel(notification.timeout) if notification.timeout
    current.splice(index, 1)

    if queue.length
      notification = queue.shift()
      add(notification)

  Notifications.getCurrent = () ->
    current

  Notifications.success = (opt = {}) ->
    opt.type = 'success'
    add(opt)

  Notifications.error = (opt = {}) ->
    opt.type = 'error'
    add(opt)

  Notifications.remove = (notification) ->
    remove(notification)

  Notifications


angular
  .module('TodoApp')
  .factory('Notifications', [
    '$timeout',
    NotificationsFactory
  ])
