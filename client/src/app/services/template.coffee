'use strict'

TemplateFactory = () ->
  Template = {}

  title = ''
  bodyClasses = ''

  Template.getTitle = () ->
    if title then "#{title} - Todo" else 'Todo'

  Template.setTitle = (newTitle) ->
    title = newTitle
    Template

  Template.getBodyClasses = () ->
    bodyClasses

  Template.setBodyClasses = (newBodyClasses) ->
    bodyClasses = newBodyClasses
    Template

  Template

angular
  .module('TodoApp')
  .factory('Template', [
    TemplateFactory
  ])
