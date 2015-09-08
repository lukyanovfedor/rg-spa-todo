angular
  .module('TodoApp', [
    'ui.router',
    'ui.bootstrap',
    'ng-token-auth',
    'templates',
    'ngProgress'
  ])
  .config(['$stateProvider', ($stateProvider) ->
    $stateProvider
      .state('auth',
        url: '/auth'
        templateUrl: 'auth.html'
        controller: 'AuthController'
        controllerAs: 'authCtrl'
      )
      .state('taskboard',
        url: '/taskboard'
        abstract: true
        templateUrl: 'taskboard.html'
        resolve:
          auth: ['$auth', '$state', ($auth, $state) ->
            $auth
              .validateUser()
              .catch(-> $state.go('auth'))
          ]
      )
      .state('taskboard.projects',
        url: '/projects'
        templateUrl: 'projects.html'
        controller: 'ProjectsController'
        controllerAs: 'projectsCtrl'
      )
  ])
  .config(['$urlRouterProvider', ($urlRouterProvider) ->
    $urlRouterProvider.otherwise '/taskboard/projects'
  ])
  .config(['$authProvider', ($authProvider) ->
    $authProvider.configure(
      apiUrl: ''
    )
  ])
  .config(['$httpProvider', ($httpProvider) ->
    $httpProvider.interceptors.unshift('ProgressInterceptorFactory')
  ])
