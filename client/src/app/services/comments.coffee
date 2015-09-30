'use strict'

CommentsFactory = ($q) ->
  Factory = {}

  comments = []

  Factory.getComments = () ->
    comments

  Factory.setComments = (data) ->
    comments = data

  Factory.create = (comment) ->
    deferred = $q.defer()

    comment
      .$create()
      .then (response) ->
        comments.push(response)
        deferred.resolve(comments)

    deferred.promise

  Factory.destroy = (comment) ->
    deferred = $q.defer()

    comment
      .$delete()
      .then (response) ->
        index = comments.indexOf(comment)
        comments.splice(index, 1) if index > -1
        deferred.resolve(comments)

    deferred.promise

  Factory

angular
  .module('TodoApp')
  .factory('Comments', [
    '$q',
    CommentsFactory
  ])
