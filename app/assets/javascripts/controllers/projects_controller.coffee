class ProjectsController
  constructor: () ->
    console.log 'Dear friend this is ProjectsController talking to you'

angular
  .module('TodoApp')
  .controller('ProjectsController', [
    ProjectsController
  ])
