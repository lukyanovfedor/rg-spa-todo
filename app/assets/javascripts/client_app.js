angular.module('TodoApp', ['ui.router', 'ui.bootstrap', 'ng-token-auth', 'ngProgress', 'ngResource']).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('auth', {
      url: '/auth',
      templateUrl: 'auth.html',
      controller: 'AuthController',
      controllerAs: 'authCtrl'
    }).state('taskboard', {
      url: '/taskboard',
      abstract: true,
      templateUrl: 'taskboard.html',
      resolve: {
        auth: [
          '$auth', '$state', function($auth, $state) {
            return $auth.validateUser()["catch"](function() {
              return $state.go('auth');
            });
          }
        ]
      }
    }).state('taskboard.projects', {
      url: '/projects',
      templateUrl: 'projects.html',
      controller: 'ProjectsController',
      controllerAs: 'projectsCtrl',
      resolve: {
        projects: [
          'ProjectResource', function(ProjectResource) {
            return ProjectResource.query().$promise;
          }
        ]
      }
    }).state('taskboard.project', {
      url: '/projects/:id',
      templateUrl: 'project.html',
      controller: 'ProjectController',
      controllerAs: 'projectCtrl',
      resolve: {
        project: [
          'ProjectResource', '$stateParams', function(ProjectResource, $stateParams) {
            return ProjectResource.get({
              id: $stateParams.id
            }).$promise;
          }
        ],
        tasks: [
          'project', 'TaskResource', function(project, TasksResource) {
            return TasksResource.query({
              projectId: project.id
            }).$promise;
          }
        ]
      }
    });
  }
]).config([
  '$urlRouterProvider', function($urlRouterProvider) {
    return $urlRouterProvider.otherwise('/taskboard/projects');
  }
]).config([
  '$httpProvider', function($httpProvider) {
    $httpProvider.interceptors.push('ProgressInterceptor');
    return $httpProvider.interceptors.push('CsrfInterceptor');
  }
]).config([
  '$authProvider', function($authProvider) {
    return $authProvider.configure({
      apiUrl: ''
    });
  }
]);

var ApplicationController;

ApplicationController = (function() {
  function ApplicationController(Template, $rootScope, $scope, $auth, $state) {
    var goToAuth, goToProjects;
    this.Template = Template;
    goToAuth = function() {
      return $state.go('auth');
    };
    goToProjects = function() {
      return $state.go('taskboard.projects');
    };
    $rootScope.$on('auth:logout-success', goToAuth);
    $rootScope.$on('auth:login-success', goToProjects);
    $rootScope.$on('auth:registration-email-success', goToProjects);
    $rootScope.$on('auth:validation-error', function() {
      return console.log('auth:validation-error');
    });
    $rootScope.$on('auth:invalid', function() {
      return console.log('auth:invalid');
    });
  }

  return ApplicationController;

})();

angular.module('TodoApp').controller('ApplicationController', ['Template', '$rootScope', '$scope', '$auth', '$state', ApplicationController]);

var AuthController;

AuthController = (function() {
  function AuthController(Template, $auth) {
    Template.setTitle('Welcome');
    Template.setBodyClasses('auth');
    this.registerData = {};
    this.register = $auth.submitRegistration.bind($auth, this.registerData);
    this.loginData = {};
    this.login = $auth.submitLogin.bind($auth, this.loginData);
  }

  return AuthController;

})();

angular.module('TodoApp').controller('AuthController', ['Template', '$auth', AuthController]);

var HeaderController;

HeaderController = (function() {
  function HeaderController($auth, $rootScope, $modal, $state) {
    this.user = $rootScope.user || {};
    this.signOut = $auth.signOut.bind($auth);
    this.isMenuOpen = false;
    this.create_project = function() {
      var modal;
      modal = $modal.open({
        templateUrl: 'modals/create_project.html',
        controller: 'ProjectModalController',
        controllerAs: 'pmc'
      });
      return modal.result.then(function(project) {
        return $state.go('taskboard.project', {
          id: project.id
        });
      });
    };
  }

  return HeaderController;

})();

angular.module('TodoApp').controller('HeaderController', ['$auth', '$rootScope', '$modal', '$state', HeaderController]);

var ProjectController;

ProjectController = (function() {
  function ProjectController(project, tasks, $state, TaskResource) {
    this.project = project;
    this.projectDestroyCallback = function() {
      return $state.go('taskboard.projects');
    };
    this.newTask = new TaskResource();
    this.addNewTask = function() {
      if (this.newTaskForm.$invalid) {
        return;
      }
      return this.newTask.$save({
        projectId: this.project.id
      }).then((function(_this) {
        return function() {
          _this.newTaskForm.$setPristine();
          return _this.newTask = new TasksResource();
        };
      })(this));
    };
  }

  return ProjectController;

})();

angular.module('TodoApp').controller('ProjectController', ['project', 'tasks', '$state', 'TaskResource', ProjectController]);

var ProjectModalController;

ProjectModalController = (function() {
  function ProjectModalController($modalInstance, ProjectResource) {
    this.project = new ProjectResource({
      title: 'New project'
    });
    this.cancel = $modalInstance.dismiss.bind($modalInstance);
    this.create = function() {
      if (this.projectNew.$invalid) {
        return;
      }
      return this.project.$save().then($modalInstance.close.bind($modalInstance, this.project))["catch"]($modalInstance.dismiss);
    };
  }

  return ProjectModalController;

})();

angular.module('TodoApp').controller('ProjectModalController', ['$modalInstance', 'ProjectResource', ProjectModalController]);

var ProjectsController;

ProjectsController = (function() {
  function ProjectsController(projects, $scope) {
    this.projects = projects || [];
    this.projectDestroyCallback = (function(_this) {
      return function(project) {
        return _this.projects = _this.projects.filter(function(p) {
          return !!p.id;
        });
      };
    })(this);
  }

  return ProjectsController;

})();

angular.module('TodoApp').controller('ProjectsController', ['projects', '$scope', ProjectsController]);

angular.module('TodoApp').factory('ProjectResource', [
  '$resource', function($resource) {
    return $resource('/projects/:id.json', {
      id: '@id'
    }, {
      update: {
        method: 'PUT'
      }
    });
  }
]);

angular.module('TodoApp').factory('TaskResource', [
  '$resource', function($resource) {
    return $resource('/projects/:projectId/tasks/:id.json', {
      id: '@id'
    }, {
      update: {
        method: 'PUT'
      }
    });
  }
]);

var hasErrorsDirective;

hasErrorsDirective = function() {
  var link, valid;
  valid = function(field, form) {
    return !(form[field].$invalid && (form[field].$dirty || form.$submitted));
  };
  link = function(scope, el) {
    var handler, input;
    input = el[0].querySelector('input, textarea');
    if (input.type && input.type === 'submit') {
      return;
    }
    handler = function(event) {
      if (valid(scope.field, scope.form)) {
        return el.removeClass('has-error');
      } else {
        return el.addClass('has-error');
      }
    };
    input.addEventListener('input', handler, false);
    return scope.$on('$destroy', function() {
      return input.removeEventListener('input', handler, false);
    });
  };
  return {
    restrict: 'A',
    scope: {
      field: '@field',
      form: '=form'
    },
    link: link
  };
};

angular.module('TodoApp').directive('hasErrors', [hasErrorsDirective]);

var lastScope;

lastScope = null;

angular.module('TodoApp').directive('projectTitle', [
  function() {
    return {
      restrict: 'E',
      templateUrl: 'directives/project_title.html',
      replace: true,
      scope: {
        project: '=project',
        destroyCb: '=destroyCb'
      },
      link: function(scope, el, attrs, ctrl) {
        var keyUpHandler;
        keyUpHandler = function(event) {
          if (event.keyCode && event.keyCode === 27 && scope.isEdit) {
            return scope.$apply(scope.cancelEdit);
          }
        };
        scope.isEdit = false;
        scope.oldTitle = '';
        scope.startEdit = function() {
          if (lastScope) {
            lastScope.cancelEdit();
          }
          document.addEventListener('keyup', keyUpHandler);
          lastScope = scope;
          scope.oldTitle = scope.project.title;
          scope.isEdit = true;
          return setTimeout(function() {
            return el[0].querySelector('input').focus();
          });
        };
        scope.cancelEdit = function(setOldTitle) {
          if (setOldTitle == null) {
            setOldTitle = true;
          }
          document.removeEventListener('keyup', keyUpHandler);
          lastScope = null;
          if (setOldTitle) {
            scope.project.title = scope.oldTitle;
          }
          scope.oldTitle = '';
          return scope.isEdit = false;
        };
        scope.finishEdit = function(form) {
          if (form.$invalid) {
            return;
          }
          if (scope.oldTitle === scope.project.title) {
            return scope.cancelEdit();
          }
          return scope.project.$update().then(scope.cancelEdit.bind(scope, false));
        };
        scope.deleteProject = function() {
          return scope.project.$delete().then((function(_this) {
            return function() {
              if (scope.destroyCb) {
                scope.destroyCb(scope.project);
              }
              return scope.cancelEdit();
            };
          })(this));
        };
        return scope.$on('$destroy', function() {
          return document.removeEventListener('keyup', keyUpHandler);
        });
      }
    };
  }
]);

var showErrorsDirective;

showErrorsDirective = function(ValidationErrors) {
  var link;
  link = function(scope, el) {
    var unwatch, watchFunk, watchValue;
    scope.errors = {};
    scope.messages = ValidationErrors;
    scope.unValid = function() {
      return scope.form[scope.field].$invalid && (scope.form[scope.field].$dirty || scope.form.$submitted);
    };
    watchFunk = function(newVal) {
      return scope.errors = newVal;
    };
    watchValue = function(scope) {
      return scope.form[scope.field].$error;
    };
    unwatch = scope.$watch(watchValue, watchFunk, true);
    return scope.$on('$destroy', function() {
      return unwatch();
    });
  };
  return {
    restrict: 'E',
    replace: true,
    templateUrl: 'directives/show_errors.html',
    scope: {
      field: '@field',
      form: '=form'
    },
    link: link
  };
};

angular.module('TodoApp').directive('showErrors', ['ValidationErrors', showErrorsDirective]);

angular.module('TodoApp').factory('CsrfInterceptor', [
  function() {
    var Interceptor, error, header;
    Interceptor = {};
    header = {
      name: 'X-CSRF-Token',
      value: 'csrf-token'
    };
    try {
      header.value = document.querySelector('meta[name="csrf-token"]').content;
    } catch (error) {
      console.warn('Unable to get csrf token');
    }
    Interceptor.request = function(config) {
      if (config.method === 'GET') {
        return config;
      }
      config.headers = config.headers || {};
      config.headers[header.name] = header.value;
      return config;
    };
    return Interceptor;
  }
]);

angular.module('TodoApp').factory('ProgressInterceptor', [
  'ngProgressFactory', function(ngProgressFactory) {
    var Interceptor, complete, progress;
    Interceptor = {};
    progress = null;
    complete = function() {
      progress.complete();
      return progress = null;
    };
    Interceptor.request = function(config) {
      progress = progress || ngProgressFactory.createInstance();
      progress.setColor('#678cf3');
      progress.start();
      return config;
    };
    Interceptor.response = function(response) {
      if (progress) {
        complete();
      }
      return response;
    };
    Interceptor.requestError = function(err) {
      if (progress) {
        complete();
      }
      return err;
    };
    Interceptor.responseError = function(err) {
      if (progress) {
        complete();
      }
      return err;
    };
    return Interceptor;
  }
]);

angular.module('TodoApp').factory('Template', [
  function() {
    return {
      _title: '',
      _bodyClasses: '',
      getTitle: function() {
        if (!this._title) {
          return 'Todo';
        }
        return this._title + " - Todo";
      },
      setTitle: function(title) {
        return this._title = title;
      },
      getBodyClasses: function() {
        return this._bodyClasses;
      },
      setBodyClasses: function(bodyClasses) {
        return this._bodyClasses = bodyClasses;
      }
    };
  }
]);

angular.module('TodoApp').value('ValidationErrors', {
  required: 'This field is required'
});

angular.module('TodoApp').run(['$templateCache', function($templateCache) {
    $templateCache.put('auth.html',
        "<div class=\"auth-forms\">\n    <div class=\"brand\">\n        Todo\n    </div>\n\n    <form ng-submit=\"authCtrl.login()\" role=\"form\" class=\"login-form\">\n        <div class=\"form-group\">\n            <label>Email</label>\n            <input type=\"email\" name=\"email\" ng-model=\"loginForm.email\" required=\"required\" class=\"form-control\"/>\n        </div>\n\n        <div class=\"form-group\">\n            <label>Password</label>\n            <input type=\"password\" name=\"password\" ng-model=\"loginForm.password\" required=\"required\" class=\"form-control\"/>\n        </div>\n\n        <button type=\"submit\" class=\"btn btn-primary btn-block\">Sign in</button>\n    </form>\n\n    <div class=\"or\">\n        <span>or</span>\n    </div>\n\n    <form ng-submit=\"authCtrl.register()\" role=\"form\" class=\"register-form\">\n        <div class=\"form-group\">\n            <label>First name</label>\n            <input type=\"text\" name=\"first_name\" ng-model=\"authCtrl.registerData.first_name\" required=\"required\" class=\"form-control\"/>\n        </div>\n\n        <div class=\"form-group\">\n            <label>Last name</label>\n            <input type=\"text\" name=\"last_name\" ng-model=\"authCtrl.registerData.last_name\" required=\"required\" class=\"form-control\"/>\n        </div>\n\n        <div class=\"form-group\">\n            <label>Email</label>\n            <input type=\"email\" name=\"email\" ng-model=\"authCtrl.registerData.email\" required=\"required\" class=\"form-control\"/>\n        </div>\n\n        <div class=\"form-group\">\n            <label>Password</label>\n            <input type=\"password\" name=\"password\" ng-model=\"authCtrl.registerData.password\" required=\"required\" class=\"form-control\"/>\n        </div>\n\n        <div class=\"form-group\">\n            <label>Password confirmation</label>\n            <input type=\"password\" name=\"password_confirmation\" ng-model=\"authCtrl.registerData.password_confirmation\" required=\"required\" class=\"form-control\"/>\n        </div>\n\n        <button type=\"submit\" class=\"btn btn-primary btn-block\">Register</button>\n    </form>\n</div>");
}]);
angular.module('TodoApp').run(['$templateCache', function($templateCache) {
    $templateCache.put('project.html',
        "<div class=\"projects-page\">\n    <div class=\"project card\">\n        <div class=\"project-title\">\n            <project-title project=\"projectCtrl.project\" destroy-cb=\"projectCtrl.projectDestroyCallback\"></project-title>\n        </div>\n    </div>\n\n    <div class=\"card add-task\">\n        <form novalidate name=\"projectCtrl.newTaskForm\" ng-submit=\"projectCtrl.addNewTask()\">\n            <div class=\"form-group\"\n                 ng-class=\"{'has-error': projectCtrl.newTaskForm.title.$invalid && (!projectCtrl.newTaskForm.title.$pristine || projectCtrl.newTaskForm.$submitted)}\">\n\n                <label>New task</label>\n\n                <input type=\"text\" name=\"title\" class=\"form-control\" ng-model=\"projectCtrl.newTask.title\" required />\n\n                <p ng-show=\"projectCtrl.newTaskForm.title.$invalid && (!projectCtrl.newTaskForm.title.$pristine || projectCtrl.newTaskForm.$submitted)\" class=\"help-block\">\n                    Title is required.\n                </p>\n            </div>\n\n            <button class=\"btn btn-primary\" type=\"submit\" ng-disabled=\"projectCtrl.newTaskForm.$invalid\">\n                Add new task\n            </button>\n        </form>\n    </div>\n</div>");
}]);
angular.module('TodoApp').run(['$templateCache', function($templateCache) {
    $templateCache.put('projects.html',
        "<div class=\"container projects-page\">\n    <div class=\"project card\"\n         ng-if=\"projectsCtrl.projects.length\"\n         ng-repeat=\"project in projectsCtrl.projects\">\n        <div class=\"project-title\">\n            <project-title project=\"project\" destroy-cb=\"projectsCtrl.projectDestroyCallback\"></project-title>\n        </div>\n    </div>\n\n    <div class=\"empty card\" ng-if=\"!projectsCtrl.projects.length\">\n        <div class=\"empty-image\">\n            <img src=\"/assets/empty.png\" />\n        </div>\n\n        <p class=\"text\">\n            You weren't have created any projects yet, but it's good that it's easy to fix ;)\n        </p>\n\n        <p class=\"text\">\n            Just select <b>\"Create new project\"</b> from user menu\n        </p>\n    </div>\n</div>");
}]);
angular.module('TodoApp').run(['$templateCache', function($templateCache) {
    $templateCache.put('taskboard.html',
        "<header ng-controller=\"HeaderController as headerCtrl\">\n    <nav class=\"navbar navbar-inverse navbar-default navbar-fixed-top\">\n        <div class=\"container\">\n            <div class=\"navbar-header\">\n                <a class=\"navbar-brand\" ui-sref=\"taskboard.projects\">Todo</a>\n            </div>\n\n            <div class=\"navbar-right\" ng-if=\"headerCtrl.user.signedIn\">\n                <div dropdown is-open=\"headerCtrl.isMenuOpen\">\n                    <div class=\"avatar\" dropdown-toggle>\n                        <img src=\"{{ headerCtrl.user.image.url }}\">\n                    </div>\n\n                    <ul class=\"dropdown-menu dropdown-menu-right\" role=\"menu\">\n                        <li>\n                            <a ui-sref=\"taskboard.projects\">\n                                My projects\n                            </a>\n                        </li>\n                        <li role=\"presentation\" class=\"divider\"></li>\n                        <li>\n                            <a ng-click=\"headerCtrl.create_project()\">\n                                Create new project\n                            </a>\n                        </li>\n                        <li role=\"presentation\" class=\"divider\"></li>\n                        <li>\n                            <a ng-click=\"headerCtrl.signOut()\">\n                                Sign out\n                            </a>\n                        </li>\n                    </ul>\n                </div>\n            </div>\n        </div>\n    </nav>\n</header>\n\n<ui-view></ui-view>");
}]);
angular.module('TodoApp').run(['$templateCache', function($templateCache) {
    $templateCache.put('directives/project_title.html',
        "<div>\n    <div class=\"not-edit\" ng-if=\"!isEdit\">\n        <div class=\"title\">{{ project.title }}</div>\n        <span ng-click=\"startEdit($event)\" class=\"edit-button\">\n            <i class=\"fa fa-pencil-square-o\"></i>\n        </span>\n        <div class=\"project-link\" ui-sref=\"taskboard.project({id: project.id})\">\n        </div>\n    </div>\n\n    <div class=\"edit\" ng-if=\"isEdit\">\n        <form role=\"form\" name=\"form\" ng-submit=\"finishEdit(this.form)\" novalidate>\n            <div class=\"form-group\" ng-class=\"{'has-error': form.title.$invalid && !form.title.$pristine}\">\n                <input type=\"text\" name=\"title\" ng-model=\"project.title\" required class=\"form-control\" />\n            </div>\n        </form>\n\n        <div class=\"controls\">\n            <span ng-click=\"finishEdit(this.form)\">\n                <i class=\"fa fa-check\"></i>\n            </span>\n\n            <span ng-click=\"cancelEdit()\">\n                <i class=\"fa fa-times\"></i>\n            </span>\n\n            <span ng-click=\"deleteProject()\">\n                <i class=\"fa fa-trash-o\"></i>\n            </span>\n        </div>\n    </div>\n</div>");
}]);
angular.module('TodoApp').run(['$templateCache', function($templateCache) {
    $templateCache.put('directives/show_errors.html',
        "<div>\n    <div class=\"validation-errors\" ng-if=\"unValid()\">\n        <p ng-repeat=\"(rule, _) in errors\" ng-if=\"messages[rule]\" class=\"help-block\">\n            {{ messages[rule] }}\n        </p>\n    </div>\n</div>");
}]);
angular.module('TodoApp').run(['$templateCache', function($templateCache) {
    $templateCache.put('modals/create_project.html',
        "<div class=\"modal-header\">\n    <h3 class=\"modal-title\">\n        Create project\n    </h3>\n</div>\n\n<div class=\"modal-body\">\n    <form role=\"form\" name=\"pmc.projectNew\" novalidate ng-submit=\"pmc.create()\">\n        <div class=\"form-group\" has-errors field=\"title\" form=\"pmc.projectNew\">\n            <label>Project title</label>\n\n            <input type=\"text\" name=\"title\" ng-model=\"pmc.project.title\" required autofocus class=\"form-control\"/>\n\n            <show-errors form=\"pmc.projectNew\" field=\"title\"></show-errors>\n        </div>\n    </form>\n</div>\n\n<div class=\"modal-footer\">\n    <button class=\"btn btn-primary\" type=\"button\" ng-click=\"pmc.create()\" ng-disabled=\"pmc.projectNew.$invalid\">Create</button>\n    <button class=\"btn btn-warning\" type=\"button\" ng-click=\"pmc.cancel()\">Cancel</button>\n</div>\n");
}]);