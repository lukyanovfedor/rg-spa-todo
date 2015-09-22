(function() {
  angular.module('TodoApp', ['ui.router', 'ui.bootstrap', 'ng-token-auth', 'ngProgress', 'ngResource', 'ngAnimate', 'FormErrors', 'angularFileUpload']).config([
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
        controllerAs: 'prjc',
        resolve: {
          project: [
            'ProjectResource', '$stateParams', function(ProjectResource, $stateParams) {
              return ProjectResource.get({
                id: $stateParams.id
              }).$promise;
            }
          ],
          tasks: [
            'project', 'TaskResource', function(project, TaskResource) {
              return TaskResource.query({
                projectId: project.id
              }).$promise;
            }
          ]
        }
      }).state('taskboard.task', {
        url: '/tasks/:id',
        templateUrl: 'task.html',
        controller: 'TaskController',
        controllerAs: 'tc',
        resolve: {
          task: [
            'TaskResource', '$stateParams', function(TaskResource, $stateParams) {
              return TaskResource.get({
                id: $stateParams.id
              }).$promise;
            }
          ],
          comments: [
            'CommentResource', '$stateParams', function(CommentResource, $stateParams) {
              return CommentResource.query({
                taskId: $stateParams.id
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

}).call(this);

(function() {
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

}).call(this);

(function() {
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

}).call(this);

(function() {
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

}).call(this);

(function() {
  var ProjectController;

  ProjectController = (function() {
    function ProjectController(project, tasks, $state, TaskResource) {
      this.project = project;
      this.tasks = tasks;
      this.formatTaskDate = function(date) {
        return moment(date).format('DD MMM YY');
      };
      this.taskExpired = function(date) {
        return parseInt(moment(date).valueOf(), 10) < parseInt(moment().startOf('day').valueOf(), 10);
      };
      this.toggleTask = function(task) {
        return task.$toggle();
      };
      this.projectDestroyCallback = function() {
        return $state.go('taskboard.projects');
      };
      this.taskDestroyCallback = (function(_this) {
        return function() {
          return _this.tasks = _this.tasks.filter(function(t) {
            return !!t.id;
          });
        };
      })(this);
      this.newTask = new TaskResource({
        project_id: this.project.id
      });
      this.addNewTask = function() {
        if (this.newTaskForm.$invalid) {
          return;
        }
        return this.newTask.$create().then((function(_this) {
          return function(task) {
            _this.tasks.push(task);
            _this.newTaskForm.$setPristine();
            return _this.newTask = new TaskResource({
              project_id: _this.project.id
            });
          };
        })(this));
      };
    }

    return ProjectController;

  })();

  angular.module('TodoApp').controller('ProjectController', ['project', 'tasks', '$state', 'TaskResource', ProjectController]);

}).call(this);

(function() {
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
        return this.project.$save().then($modalInstance.close.bind($modalInstance, this.project))["catch"](this.cancel);
      };
    }

    return ProjectModalController;

  })();

  angular.module('TodoApp').controller('ProjectModalController', ['$modalInstance', 'ProjectResource', ProjectModalController]);

}).call(this);

(function() {
  var ProjectsController;

  ProjectsController = (function() {
    function ProjectsController(projects, $scope) {
      this.projects = projects || [];
      this.projectDestroyCallback = (function(_this) {
        return function() {
          return _this.projects = _this.projects.filter(function(p) {
            return !!p.id;
          });
        };
      })(this);
    }

    return ProjectsController;

  })();

  angular.module('TodoApp').controller('ProjectsController', ['projects', '$scope', ProjectsController]);

}).call(this);

(function() {
  var TaskController;

  TaskController = (function() {
    function TaskController(task, comments, CommentResource) {
      this.task = task;
      this.comments = comments;
      this.newComment = new CommentResource({
        task_id: this.task.id,
        files: []
      });
      this.formatCommentDate = function(date) {
        return moment(date).format('h:mma MMMM Do YYYY');
      };
      this.destroyComment = function(comment) {
        return comment.$delete().then((function(_this) {
          return function(comment) {
            return _this.comments = _this.comments.filter(function(c) {
              return c.id !== comment.id;
            });
          };
        })(this));
      };
      this.addNewComment = function() {
        if (this.newCommentForm.$invalid) {
          return;
        }
        return this.newComment.$create().then((function(_this) {
          return function(comment) {
            _this.comments.push(comment);
            _this.newCommentForm.$setPristine();
            return _this.newComment = new CommentResource({
              task_id: _this.task.id,
              files: []
            });
          };
        })(this));
      };
    }

    return TaskController;

  })();

  angular.module('TodoApp').controller('TaskController', ['task', 'comments', 'CommentResource', TaskController]);

}).call(this);

(function() {
  angular.module('TodoApp').directive('appLoading', [
    '$animate', function($animate) {
      return {
        restrict: 'C',
        link: function(scope, element, attrs) {
          var removePreloader;
          removePreloader = function() {
            return $animate.leave(element.children()).then(function() {
              element.remove();
              return scope = element = attrs = null;
            });
          };
          return removePreloader();
        }
      };
    }
  ]);

}).call(this);

(function() {
  var EditableDirective;

  EditableDirective = function() {
    var lastScope, link;
    lastScope = null;
    link = function(scope, el) {
      var keyUpHandler;
      scope.hasDeadline = scope.model.hasOwnProperty('deadline');
      scope.original = {
        title: scope.model.title,
        deadline: scope.model.deadline
      };
      scope.needToUpdate = function() {
        var deadlineChanged, titleChanged;
        titleChanged = scope.model.title !== scope.original.title;
        deadlineChanged = scope.model.deadline !== scope.original.deadline;
        return titleChanged || deadlineChanged;
      };
      scope.cancel = function(setOldValues) {
        if (setOldValues == null) {
          setOldValues = true;
        }
        if (setOldValues) {
          scope.model.title = scope.original.title;
          if (scope.hasDeadline) {
            scope.model.deadline = scope.original.deadline;
          }
        }
        lastScope = null;
        return scope.model.isEdit = false;
      };
      scope.finish = function(form) {
        if (form.$invalid) {
          return;
        }
        if (!scope.needToUpdate()) {
          return scope.cancel();
        }
        return scope.model.$update().then(scope.cancel.bind(scope, false));
      };
      scope["delete"] = function() {
        return scope.model.$delete().then((function(_this) {
          return function() {
            scope.cancel();
            if (scope.destroyCb) {
              return scope.destroyCb(scope.model);
            }
          };
        })(this));
      };
      keyUpHandler = function(event) {
        if (event.keyCode && event.keyCode === 27) {
          return scope.$apply(scope.cancel);
        }
      };
      if (lastScope) {
        lastScope.cancel();
      }
      lastScope = scope;
      el[0].querySelector('input').focus();
      document.addEventListener('keyup', keyUpHandler);
      return scope.$on('$destroy', function() {
        return document.removeEventListener('keyup', keyUpHandler);
      });
    };
    return {
      restrict: 'E',
      templateUrl: 'directives/editable.html',
      replace: true,
      scope: {
        model: '=',
        destroyCb: '='
      },
      link: link
    };
  };

  angular.module('TodoApp').directive('editable', [EditableDirective]);

}).call(this);

(function() {
  var FilesUploadDirective;

  FilesUploadDirective = function() {
    var ctrl, link;
    ctrl = function($scope) {
      return $scope.files = $scope.files || [];
    };
    link = function(scope, el) {
      var drop, input;
      drop = angular.element(el[0].querySelector('.drop-area'));
      input = angular.element(el[0].querySelector('input'));
      drop.on('dragover', (function(_this) {
        return function(ev) {
          ev.preventDefault();
          ev.stopPropagation();
          return el.addClass('dragover');
        };
      })(this));
      drop.on('dragleave', (function(_this) {
        return function(ev) {
          ev.preventDefault();
          ev.stopPropagation();
          return el.removeClass('dragover');
        };
      })(this));
      return drop.on('drop', (function(_this) {
        return function(ev) {
          var dataTransfer, file, files, i, len;
          ev.preventDefault();
          ev.stopPropagation();
          el.removeClass('dragover');
          dataTransfer = ev.dataTransfer ? ev.dataTransfer : ev.originalEvent.dataTransfer;
          files = dataTransfer.files;
          for (i = 0, len = files.length; i < len; i++) {
            file = files[i];
            scope.files.push(file);
          }
          return scope.$apply();
        };
      })(this));
    };
    return {
      restrict: 'A',
      replace: true,
      scope: {
        files: '=filesUpload'
      },
      template: ['<div class="files-upload">', '<div class="drop-area"></div>', '<input type="file" multiple />', '</div>'].join(''),
      controller: ['$scope', ctrl],
      link: link
    };
  };

  angular.module('TodoApp').directive('filesUpload', [FilesUploadDirective]);

}).call(this);

(function() {
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

}).call(this);

(function() {
  var showErrorsDirective;

  showErrorsDirective = function() {
    return {
      restrict: 'E',
      replace: true,
      require: '^form',
      template: ['<div ng-if="form.$dirty" class="validation-errors">', '<form-errors errors-tmpl="directives/show_errors.html"></form-errors>', '</div>'].join(''),
      link: function(scope, el, attrs, form) {
        return scope.form = form;
      }
    };
  };

  angular.module('TodoApp').directive('showErrors', [showErrorsDirective]);

}).call(this);

(function() {
  angular.module('TodoApp').factory('CommentResource', [
    '$resource', function($resource) {
      return $resource('/comments/:id.json', {
        id: '@id'
      }, {
        update: {
          method: 'PUT'
        },
        query: {
          url: '/tasks/:taskId/comments.json',
          isArray: true,
          params: {
            taskId: '@task_id'
          }
        },
        create: {
          url: '/tasks/:taskId/comments.json',
          method: 'POST',
          params: {
            taskId: '@task_id'
          },
          headers: {
            'Content-Type': void 0,
            enctype: 'multipart/form-data'
          },
          transformRequest: function(data) {
            var formData, key, value;
            formData = new FormData();
            for (key in data) {
              value = data[key];
              if (key === 'files') {
                data.files.forEach(function(file) {
                  return formData.append("comment[files][]", file, file.name);
                });
              } else {
                formData.append("comment[" + key + "]", value);
              }
            }
            return formData;
          }
        }
      });
    }
  ]);

}).call(this);

(function() {
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

}).call(this);

(function() {
  angular.module('TodoApp').factory('TaskResource', [
    '$resource', function($resource) {
      return $resource('/tasks/:id/:action.json', {
        id: '@id'
      }, {
        update: {
          method: 'PUT',
          transformRequest: [
            function(data) {
              if (data.deadline) {
                data.deadline = moment(data.deadline).format('DD-MM-YYYY');
              }
              return angular.toJson(data);
            }
          ]
        },
        toggle: {
          method: 'PUT',
          params: {
            action: 'toggle'
          }
        },
        query: {
          url: '/projects/:projectId/tasks.json',
          isArray: true,
          params: {
            projectId: '@project_id'
          }
        },
        create: {
          url: '/projects/:projectId/tasks.json',
          method: 'POST',
          params: {
            projectId: '@project_id'
          },
          transformRequest: [
            function(data) {
              if (data.deadline) {
                data.deadline = moment(data.deadline).format('DD-MM-YYYY');
              }
              return angular.toJson(data);
            }
          ]
        }
      });
    }
  ]);

}).call(this);

(function() {
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

}).call(this);

(function() {
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

}).call(this);

(function() {
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

}).call(this);

angular.module('TodoApp').run(['$templateCache', function($templateCache) {
    $templateCache.put('auth.html',
        "<div class=\"auth-forms\">\n    <div class=\"brand\">\n        Todo\n    </div>\n\n    <form ng-submit=\"authCtrl.login()\" role=\"form\" class=\"login-form\">\n        <div class=\"form-group\">\n            <label>Email</label>\n            <input type=\"email\" name=\"email\" ng-model=\"loginForm.email\" required=\"required\" class=\"form-control\"/>\n        </div>\n\n        <div class=\"form-group\">\n            <label>Password</label>\n            <input type=\"password\" name=\"password\" ng-model=\"loginForm.password\" required=\"required\" class=\"form-control\"/>\n        </div>\n\n        <button type=\"submit\" class=\"btn btn-primary btn-block\">Sign in</button>\n    </form>\n\n    <div class=\"or\">\n        <span>or</span>\n    </div>\n\n    <form ng-submit=\"authCtrl.register()\" role=\"form\" class=\"register-form\">\n        <div class=\"form-group\">\n            <label>First name</label>\n            <input type=\"text\" name=\"first_name\" ng-model=\"authCtrl.registerData.first_name\" required=\"required\" class=\"form-control\"/>\n        </div>\n\n        <div class=\"form-group\">\n            <label>Last name</label>\n            <input type=\"text\" name=\"last_name\" ng-model=\"authCtrl.registerData.last_name\" required=\"required\" class=\"form-control\"/>\n        </div>\n\n        <div class=\"form-group\">\n            <label>Email</label>\n            <input type=\"email\" name=\"email\" ng-model=\"authCtrl.registerData.email\" required=\"required\" class=\"form-control\"/>\n        </div>\n\n        <div class=\"form-group\">\n            <label>Password</label>\n            <input type=\"password\" name=\"password\" ng-model=\"authCtrl.registerData.password\" required=\"required\" class=\"form-control\"/>\n        </div>\n\n        <div class=\"form-group\">\n            <label>Password confirmation</label>\n            <input type=\"password\" name=\"password_confirmation\" ng-model=\"authCtrl.registerData.password_confirmation\" required=\"required\" class=\"form-control\"/>\n        </div>\n\n        <button type=\"submit\" class=\"btn btn-primary btn-block\">Register</button>\n    </form>\n</div>");
}]);
angular.module('TodoApp').run(['$templateCache', function($templateCache) {
    $templateCache.put('project.html',
        "<div class=\"dashboard\">\n    <div class=\"main card\">\n        <div class=\"not-edit\" ng-if=\"!prjc.project.isEdit\">\n            <div class=\"title\">{{ prjc.project.title }}</div>\n\n            <span ng-click=\"prjc.project.isEdit = true\" class=\"edit-button\">\n                <i class=\"fa fa-pencil-square-o\"></i>\n            </span>\n        </div>\n\n        <div class=\"edit\" ng-if=\"prjc.project.isEdit\">\n            <editable model=\"prjc.project\" destroy-cb=\"prjc.projectDestroyCallback\">\n            </editable>\n        </div>\n    </div>\n\n    <div class=\"tasks card\" ng-if=\"prjc.tasks.length\">\n        <div class=\"task clearfix {{ task.state }}\" ng-repeat=\"task in prjc.tasks\">\n            <div class=\"not-edit\" ng-if=\"!task.isEdit\">\n                <div class=\"task-state\">\n                    <div class=\"custom-checkbox\" ng-click=\"prjc.toggleTask(task)\">\n                    </div>\n                </div>\n\n                <div class=\"task-title\">\n                    {{ task.title }}\n                </div>\n\n                <div class=\"task-deadline\"\n                    ng-if=\"task.deadline\"\n                    ng-class=\"{'expired': prjc.taskExpired(task.deadline)}\">\n                    {{ prjc.formatTaskDate(task.deadline) }}\n                </div>\n\n                <span ng-click=\"task.isEdit = true\" class=\"edit-button\">\n                    <i class=\"fa fa-pencil-square-o\"></i>\n                </span>\n\n                <div class=\"task-link\" ui-sref=\"taskboard.task({id: task.id})\">\n                </div>\n            </div>\n\n            <div class=\"edit\" ng-if=\"task.isEdit\">\n                <editable model=\"task\" destroy-cb=\"prjc.taskDestroyCallback\">\n                </editable>\n            </div>\n        </div>\n    </div>\n\n    <div class=\"card add-task\">\n        <form novalidate name=\"prjc.newTaskForm\" ng-submit=\"prjc.addNewTask()\">\n            <div class=\"add-deadline\">\n                <a ng-click=\"open = !open\"\n                   datepicker-popup=\"yyyy-MM-dd\"\n                   ng-model=\"prjc.newTask.deadline\"\n                   is-open=\"open\"\n                   show-button-bar=\"false\">\n                  {{ prjc.newTask.deadline ? 'Edit deadline' : 'Add deadline' }}\n                </a>\n            </div>\n\n            <div class=\"form-group\" has-errors field=\"title\" form=\"prjc.newTaskForm\">\n                <label>New task</label>\n\n                <input type=\"text\" name=\"title\" class=\"form-control\" ng-model=\"prjc.newTask.title\" required />\n\n                <show-errors></show-errors>\n            </div>\n\n            <button class=\"btn btn-primary\" type=\"submit\" ng-disabled=\"prjc.newTaskForm.$invalid\">\n                Add new task\n            </button>\n        </form>\n    </div>\n</div>");
}]);
angular.module('TodoApp').run(['$templateCache', function($templateCache) {
    $templateCache.put('projects.html',
        "<div class=\"container dashboard\">\n    <div class=\"main card\"\n         ng-if=\"projectsCtrl.projects.length\"\n         ng-repeat=\"project in projectsCtrl.projects\">\n        <div class=\"not-edit\" ng-if=\"!project.isEdit\">\n            <div class=\"title\">{{ project.title }}</div>\n            <span ng-click=\"project.isEdit = true\" class=\"edit-button\">\n                <i class=\"fa fa-pencil-square-o\"></i>\n            </span>\n\n            <div class=\"project-link\" ui-sref=\"taskboard.project({id: project.id})\">\n            </div>\n        </div>\n\n        <div class=\"edit\" ng-if=\"project.isEdit\">\n            <editable model=\"project\" destroy-cb=\"projectsCtrl.projectDestroyCallback\">\n            </editable>\n        </div>\n    </div>\n\n    <div class=\"empty card\" ng-if=\"!projectsCtrl.projects.length\">\n        <div class=\"empty-image\">\n            <img src=\"/assets/empty.png\" />\n        </div>\n\n        <p class=\"text\">\n            You weren't have created any projects yet, but it's good that it's easy to fix ;)\n        </p>\n\n        <p class=\"text\">\n            Just select <b>\"Create new project\"</b> from user menu\n        </p>\n    </div>\n</div>");
}]);
angular.module('TodoApp').run(['$templateCache', function($templateCache) {
    $templateCache.put('task.html',
        "<div class=\"dashboard\">\n    <div class=\"back-button-wrap\">\n        <div class=\"back-button\" ui-sref=\"taskboard.project({id: tc.task.project_id})\">\n            back to project\n        </div>\n    </div>\n\n    <div class=\"main task-card card\">\n        <div class=\"not-edit\" ng-if=\"!tc.task.isEdit\">\n            <div class=\"title\">{{ tc.task.title }}</div>\n\n            <span ng-click=\"tc.task.isEdit = true\" class=\"edit-button\">\n                <i class=\"fa fa-pencil-square-o\"></i>\n            </span>\n        </div>\n\n        <div class=\"edit\" ng-if=\"tc.task.isEdit\">\n            <editable model=\"tc.task.\" destroy-cb=\"yoy\">\n            </editable>\n        </div>\n    </div>\n\n    <div class=\"comments card\" ng-if=\"tc.comments.length\">\n        <div class=\"comment\" ng-repeat=\"comment in tc.comments\">\n            <div class=\"comment-created\">\n                <i class=\"fa fa-clock-o\"></i> {{ tc.formatCommentDate(comment.updated_at) }}\n            </div>\n\n            <div class=\"comment-note\">\n                {{ comment.note }}\n            </div>\n\n            <div class=\"controls\">\n                <span class=\"destroy-comment\" ng-click=\"tc.destroyComment(comment)\">\n                    <i class=\"fa fa-times\"></i>\n                </span>\n            </div>\n\n            <div class=\"comment-attachments\">\n                <div class=\"attachment\" ng-repeat=\"file in comment.files\">\n                    <a href=\"{{ file.url }}\" target=\"_blank\">{{file.filename}}</a>\n                </div>\n            </div>\n        </div>\n    </div>\n\n    <div class=\"card add-comment\">\n        <form novalidate name=\"tc.newCommentForm\" enctype=\"multipart/form-data\" ng-submit=\"tc.addNewComment()\">\n            <div files-upload=\"tc.newComment.files\"></div>\n\n            <ul>\n                <li ng-repeat=\"f in tc.newComment.files\">\n                    {{ f.name }}\n                </li>\n            </ul>\n\n            <div class=\"form-group\" has-errors field=\"note\" form=\"tc.newCommentForm\">\n                <label>Comment</label>\n\n                <textarea class=\"form-control\" ng-model=\"tc.newComment.note\" name=\"note\" required></textarea>\n\n                <show-errors></show-errors>\n            </div>\n\n            <button class=\"btn btn-primary\" type=\"submit\">\n                Add comment\n            </button>\n        </form>\n    </div>\n</div>");
}]);
angular.module('TodoApp').run(['$templateCache', function($templateCache) {
    $templateCache.put('taskboard.html',
        "<header ng-controller=\"HeaderController as headerCtrl\">\n    <nav class=\"navbar navbar-inverse navbar-default navbar-fixed-top\">\n        <div class=\"container\">\n            <div class=\"navbar-header\">\n                <a class=\"navbar-brand\" ui-sref=\"taskboard.projects\">Todo</a>\n            </div>\n\n            <div class=\"navbar-right\" ng-if=\"headerCtrl.user.signedIn\">\n                <div dropdown is-open=\"headerCtrl.isMenuOpen\">\n                    <div class=\"avatar\" dropdown-toggle>\n                        <img src=\"{{ headerCtrl.user.image.url }}\">\n                    </div>\n\n                    <ul class=\"dropdown-menu dropdown-menu-right\" role=\"menu\">\n                        <li>\n                            <a ui-sref=\"taskboard.projects\">\n                                My projects\n                            </a>\n                        </li>\n                        <li role=\"presentation\" class=\"divider\"></li>\n                        <li>\n                            <a ng-click=\"headerCtrl.create_project()\">\n                                Create new project\n                            </a>\n                        </li>\n                        <li role=\"presentation\" class=\"divider\"></li>\n                        <li>\n                            <a ng-click=\"headerCtrl.signOut()\">\n                                Sign out\n                            </a>\n                        </li>\n                    </ul>\n                </div>\n            </div>\n        </div>\n    </nav>\n</header>\n\n<ui-view></ui-view>");
}]);
angular.module('TodoApp').run(['$templateCache', function($templateCache) {
    $templateCache.put('directives/editable.html',
        "<div>\n    <form role=\"form\" name=\"form\" ng-submit=\"finish(this.form)\" novalidate>\n        <div class=\"form-group\" has-errors field=\"title\" form=\"form\">\n            <input type=\"text\" name=\"title\" ng-model=\"model.title\" required class=\"form-control\" />\n        </div>\n    </form>\n\n    <div class=\"controls\">\n        <span ng-click=\"finish(this.form)\">\n            <i class=\"fa fa-check\"></i>\n        </span>\n\n        <span ng-if=\"hasDeadline\"\n              ng-click=\"open = !open\"\n              datepicker-popup=\"yyyy-MM-dd\"\n              ng-model=\"model.deadline\"\n              is-open=\"open\"\n              show-button-bar=\"false\">\n            <i class=\"fa fa-calendar\"></i>\n        </span>\n\n        <span ng-click=\"cancel()\">\n            <i class=\"fa fa-times\"></i>\n        </span>\n\n        <span ng-click=\"delete()\">\n            <i class=\"fa fa-trash-o\"></i>\n        </span>\n    </div>\n</div>");
}]);
angular.module('TodoApp').run(['$templateCache', function($templateCache) {
    $templateCache.put('directives/show_errors.html',
        "<div>\n    <p ng-repeat=\"error in errors track by $index\" class=\"help-block\">\n        {{ error.message }}\n    </p>\n</div>");
}]);
angular.module('TodoApp').run(['$templateCache', function($templateCache) {
    $templateCache.put('modals/create_project.html',
        "<div class=\"modal-header\">\n    <h3 class=\"modal-title\">\n        Create project\n    </h3>\n</div>\n\n<div class=\"modal-body\">\n    <form role=\"form\" name=\"pmc.projectNew\" novalidate ng-submit=\"pmc.create()\">\n        <div class=\"form-group\" has-errors field=\"title\" form=\"pmc.projectNew\">\n            <label>Project title</label>\n\n            <input type=\"text\" name=\"title\" ng-model=\"pmc.project.title\" required autofocus class=\"form-control\"/>\n\n            <show-errors></show-errors>\n        </div>\n    </form>\n</div>\n\n<div class=\"modal-footer\">\n    <button class=\"btn btn-primary\" type=\"button\" ng-click=\"pmc.create()\" ng-disabled=\"pmc.projectNew.$invalid\">Create</button>\n    <button class=\"btn btn-warning\" type=\"button\" ng-click=\"pmc.cancel()\">Cancel</button>\n</div>\n");
}]);