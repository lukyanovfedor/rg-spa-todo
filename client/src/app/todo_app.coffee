'use strict'

angular
  .module('TodoApp', [
    'ui.router',
    'ui.bootstrap',
    'as.sortable',
    'ng-token-auth',
    'ngProgress',
    'ngResource',
    'ngAnimate',
    'ngMessages'
  ])
  .config(['$stateProvider', ($stateProvider) ->
    $stateProvider
      .state('auth',
        url: '/auth'
        templateUrl: 'templates/auth.html'
        controller: 'AuthController'
        controllerAs: 'authCtrl'
        resolve:
          auth: ['$auth', '$state', '$q', ($auth, $state, $q) ->
            deferred = $q.defer()

            $auth
              .validateUser()
              .then () ->
                $state.go('taskboard.projects')
              .catch () ->
                deferred.resolve()

            deferred.promise
          ]
      )
      .state('taskboard',
        url: '/taskboard'
        abstract: true
        templateUrl: 'templates/taskboard.html'
        resolve:
          auth: ['$auth', '$state', '$q', ($auth, $state, $q) ->
            deferred = $q.defer()

            $auth
              .validateUser()
              .then (response) ->
                deferred.resolve(response)
              .catch () ->
                $state.go('auth')

            deferred.promise
          ]
      )
      .state('taskboard.projects',
        url: '/projects'
        templateUrl: 'templates/projects.html'
        controller: 'ProjectsController'
        controllerAs: 'projectsCtrl'
        resolve:
          projects: ['ProjectResource', (ProjectResource) ->
            ProjectResource.query().$promise
          ]
      )
      .state('taskboard.task',
        url: '/tasks/:id'
        templateUrl: 'templates/task.html'
        controller: 'TaskController'
        controllerAs: 'taskCtrl'
        resolve:
          task: ['TaskResource', '$stateParams', (TaskResource, $stateParams) ->
            TaskResource.get(id: $stateParams.id).$promise
          ]
          comments: ['CommentResource', '$stateParams', (CommentResource, $stateParams) ->
            CommentResource.query(taskId: $stateParams.id).$promise
          ]
      )
  ])
  .config(['$urlRouterProvider', ($urlRouterProvider) ->
    $urlRouterProvider.otherwise '/auth'
  ])
  .config(['$httpProvider', ($httpProvider) ->
    $httpProvider.interceptors.push('ErrorHandlingInterceptor', 'ProgressInterceptor', 'CsrfInterceptor')
  ])
  .config(['$authProvider', ($authProvider) ->
    $authProvider.configure(
      apiUrl: ''
      omniauthWindowType: 'newWindow'
    )
  ])
