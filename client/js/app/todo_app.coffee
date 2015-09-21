angular
  .module('TodoApp', [
    'ui.router',
    'ui.bootstrap',
    'ng-token-auth',
    'ngProgress',
    'ngResource',
    'ngAnimate'
    'FormErrors'
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
            $auth.validateUser().catch(-> $state.go('auth'))
          ]
      )
      .state('taskboard.projects',
        url: '/projects'
        templateUrl: 'projects.html'
        controller: 'ProjectsController'
        controllerAs: 'projectsCtrl'
        resolve:
          projects: ['ProjectResource', (ProjectResource) ->
            ProjectResource.query().$promise
          ]
      )
      .state('taskboard.project',
        url: '/projects/:id'
        templateUrl: 'project.html'
        controller: 'ProjectController'
        controllerAs: 'prjc'
        resolve:
          project: ['ProjectResource', '$stateParams', (ProjectResource, $stateParams) ->
            ProjectResource.get(id: $stateParams.id).$promise
          ]
          tasks: ['project', 'TaskResource', (project, TaskResource) ->
            TaskResource.query(projectId: project.id).$promise
          ]
      )
      .state('taskboard.task',
        url: '/tasks/:id'
        templateUrl: 'task.html'
        controller: 'TaskController'
        controllerAs: 'tc'
        resolve:
          task: ['TaskResource', '$stateParams', (TaskResource, $stateParams) ->
            TaskResource.get(id: $stateParams.id).$promise
          ]
      )
  ])
  .config(['$urlRouterProvider', ($urlRouterProvider) ->
    $urlRouterProvider.otherwise '/taskboard/projects'
  ])
  .config(['$httpProvider', ($httpProvider) ->
    $httpProvider.interceptors.push('ProgressInterceptor')
    $httpProvider.interceptors.push('CsrfInterceptor')
  ])
  .config(['$authProvider', ($authProvider) ->
    $authProvider.configure(
      apiUrl: ''
    )
  ])
