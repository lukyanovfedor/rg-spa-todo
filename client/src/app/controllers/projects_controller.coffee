'use strict'

class ProjectsController
  constructor: ($scope, projects, Template, Notifications, Projects) ->
    @projects = projects

    @edit = (project) ->
      project.isEdit = true

    @destroyCb = (project) =>
      index = @projects.indexOf(project)
      @projects.splice(index, 1) if index > -1
      Notifications.success(text: 'Project deleted.')

    @updateCb = (project) =>
      Notifications.success(text: 'Project updated.')

    Projects.setProjects(@projects)
    Template.setTitle('Projects').setBodyClasses('projects-list')

angular
  .module('TodoApp')
  .controller('ProjectsController', [
    '$scope',
    'projects',
    'Template',
    'Notifications',
    'Projects',
    ProjectsController
  ])
