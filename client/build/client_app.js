(function() {
  'use strict';
  angular.module('TodoApp', ['ui.router', 'ui.bootstrap', 'as.sortable', 'ng-token-auth', 'ngProgress', 'ngResource', 'ngAnimate', 'ngMessages']).config([
    '$stateProvider', function($stateProvider) {
      return $stateProvider.state('auth', {
        url: '/auth',
        templateUrl: 'templates/auth.html',
        controller: 'AuthController',
        controllerAs: 'authCtrl',
        resolve: {
          auth: [
            '$auth', '$state', '$q', function($auth, $state, $q) {
              var deferred;
              deferred = $q.defer();
              $auth.validateUser().then(function() {
                return $state.go('taskboard.projects');
              })["catch"](function() {
                return deferred.resolve();
              });
              return deferred.promise;
            }
          ]
        }
      }).state('taskboard', {
        url: '/taskboard',
        abstract: true,
        templateUrl: 'templates/taskboard.html',
        resolve: {
          auth: [
            '$auth', '$state', '$q', function($auth, $state, $q) {
              var deferred;
              deferred = $q.defer();
              $auth.validateUser().then(function(response) {
                return deferred.resolve(response);
              })["catch"](function() {
                return $state.go('auth');
              });
              return deferred.promise;
            }
          ]
        }
      }).state('taskboard.projects', {
        url: '/projects',
        templateUrl: 'templates/projects.html',
        controller: 'ProjectsController',
        controllerAs: 'projectsCtrl',
        resolve: {
          projects: [
            'ProjectResource', function(ProjectResource) {
              return ProjectResource.query().$promise;
            }
          ]
        }
      }).state('taskboard.task', {
        url: '/tasks/:id',
        templateUrl: 'templates/task.html',
        controller: 'TaskController',
        controllerAs: 'taskCtrl',
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
      return $urlRouterProvider.otherwise('/auth');
    }
  ]).config([
    '$httpProvider', function($httpProvider) {
      return $httpProvider.interceptors.push('ErrorHandlingInterceptor', 'ProgressInterceptor', 'CsrfInterceptor');
    }
  ]).config([
    '$authProvider', function($authProvider) {
      return $authProvider.configure({
        apiUrl: '',
        omniauthWindowType: 'newWindow'
      });
    }
  ]);

}).call(this);

(function() {
  'use strict';
  var AuthController;

  AuthController = (function() {
    function AuthController($auth, $scope, Template) {
      this.registerData = {};
      this.register = function() {
        if (this.regForm.$invalid) {
          return;
        }
        return $auth.submitRegistration(this.registerData);
      };
      this.loginData = {};
      this.login = function() {
        if (this.loginForm.$invalid) {
          return;
        }
        return $auth.submitLogin(this.loginData);
      };
      this.facebook = function() {
        return $auth.authenticate('facebook');
      };
      Template.setTitle('Welcome').setBodyClasses('auth');
    }

    return AuthController;

  })();

  angular.module('TodoApp').controller('AuthController', ['$auth', '$scope', 'Template', AuthController]);

}).call(this);

(function() {
  'use strict';
  var CommentsController;

  CommentsController = (function() {
    function CommentsController(Comments, CommentResource, AttachmentResource, Notifications) {
      var create, resetForm, update;
      this.comments = Comments.getComments();
      this.newComment = new CommentResource({
        attachments: []
      });
      this.formatUpdated = function(comment) {
        return moment(comment.updated_at).format('h:mma MMMM Do YYYY');
      };
      this.edit = function(comment) {
        if (this.cancel.original) {
          this.cancel(false);
        }
        this.cancel.original = angular.copy(comment);
        comment.isEdit = true;
        return resetForm(comment);
      };
      this.cancel = function(needToReset) {
        if (needToReset == null) {
          needToReset = true;
        }
        if (this.cancel.original) {
          this.cancel.original.attachments = this.newComment.attachments.filter(function(a) {
            return !!a.id;
          });
          angular.extend(this.newComment, this.cancel.original);
          this.cancel.original = null;
        }
        this.newComment.isEdit = false;
        if (needToReset) {
          return resetForm();
        }
      };
      this.destroy = function(comment) {
        return Comments.destroy(comment).then(function() {
          return Notifications.success({
            text: 'Comment deleted.'
          });
        });
      };
      this.submit = function(task) {
        if (this.form.$invalid) {
          return;
        }
        if (this.newComment.id) {
          return update();
        } else {
          return create(task);
        }
      };
      this.removeAttachment = (function(_this) {
        return function(attachment) {
          var index;
          if (attachment.id) {
            return AttachmentResource["delete"]({
              id: attachment.id
            }).$promise.then(function(response) {
              Notifications.success({
                text: 'Attachment deleted.'
              });
              return _this.newComment.attachments = _this.newComment.attachments.filter(function(a) {
                return a.id !== response.id;
              });
            });
          } else {
            index = _this.newComment.attachments.indexOf(attachment);
            if (index > -1) {
              return _this.newComment.attachments.splice(index, 1);
            }
          }
        };
      })(this);
      update = (function(_this) {
        return function() {
          return _this.newComment.$update().then(function() {
            Notifications.success({
              text: 'Comment updated.'
            });
            return resetForm();
          });
        };
      })(this);
      create = (function(_this) {
        return function(task) {
          _this.newComment.task_id = task.id;
          return Comments.create(_this.newComment).then(function() {
            Notifications.success({
              text: 'Comment created.'
            });
            return resetForm();
          });
        };
      })(this);
      resetForm = (function(_this) {
        return function(comment) {
          _this.form.$setPristine();
          if (comment) {
            return _this.newComment = comment;
          } else {
            return _this.newComment = new CommentResource({
              attachments: []
            });
          }
        };
      })(this);
    }

    return CommentsController;

  })();

  angular.module('TodoApp').controller('CommentsController', ['Comments', 'CommentResource', 'AttachmentResource', 'Notifications', CommentsController]);

}).call(this);

(function() {
  'use strict';
  var HeaderController;

  HeaderController = (function() {
    function HeaderController($rootScope, $auth, $state, Projects, Notifications) {
      this.user = $rootScope.user;
      this.signOut = function() {
        return $auth.signOut();
      };
      this.createProject = function() {
        return Projects.newProjectModal().then(function() {
          Notifications.success({
            text: 'Project created.'
          });
          if (!$state.is('taskboard.projects')) {
            return $state.go('taskboard.projects');
          }
        });
      };
    }

    return HeaderController;

  })();

  angular.module('TodoApp').controller('HeaderController', ['$rootScope', '$auth', '$state', 'Projects', 'Notifications', HeaderController]);

}).call(this);

(function() {
  'use strict';
  var MainController;

  MainController = (function() {
    function MainController($rootScope, $auth, $state, Template, Notifications) {
      var goToAuth, goToProjects;
      this.Template = Template;
      this.notifications = Notifications.getCurrent();
      this.removeNotification = function(notification) {
        return Notifications.remove(notification);
      };
      goToAuth = function() {
        return $state.go('auth');
      };
      goToProjects = function() {
        return $state.go('taskboard.projects');
      };
      $rootScope.$on('auth:logout-success', goToAuth);
      $rootScope.$on('auth:validation-error', goToAuth);
      $rootScope.$on('auth:invalid', goToAuth);
      $rootScope.$on('auth:login-success', goToProjects);
      $rootScope.$on('auth:registration-email-success', goToProjects);
    }

    return MainController;

  })();

  angular.module('TodoApp').controller('MainController', ['$rootScope', '$auth', '$state', 'Template', 'Notifications', MainController]);

}).call(this);

(function() {
  'use strict';
  var NewProjectModalController;

  NewProjectModalController = (function() {
    function NewProjectModalController($modalInstance, ProjectResource) {
      this.project = new ProjectResource({
        title: 'New project'
      });
      this.cancel = function() {
        return $modalInstance.dismiss();
      };
      this.submit = function() {
        if (this.form.$invalid) {
          return;
        }
        return this.project.$save().then((function(_this) {
          return function() {
            return $modalInstance.close(_this.project);
          };
        })(this));
      };
    }

    return NewProjectModalController;

  })();

  angular.module('TodoApp').controller('NewProjectModalController', ['$modalInstance', 'ProjectResource', NewProjectModalController]);

}).call(this);

(function() {
  'use strict';
  var ProjectsController;

  ProjectsController = (function() {
    function ProjectsController($scope, projects, Template, Notifications, Projects) {
      this.projects = projects;
      this.edit = function(project) {
        return project.isEdit = true;
      };
      this.destroyCb = (function(_this) {
        return function(project) {
          var index;
          index = _this.projects.indexOf(project);
          if (index > -1) {
            _this.projects.splice(index, 1);
          }
          return Notifications.success({
            text: 'Project deleted.'
          });
        };
      })(this);
      this.updateCb = (function(_this) {
        return function(project) {
          return Notifications.success({
            text: 'Project updated.'
          });
        };
      })(this);
      Projects.setProjects(this.projects);
      Template.setTitle('Projects').setBodyClasses('projects-list');
    }

    return ProjectsController;

  })();

  angular.module('TodoApp').controller('ProjectsController', ['$scope', 'projects', 'Template', 'Notifications', 'Projects', ProjectsController]);

}).call(this);

(function() {
  'use strict';
  var TaskController;

  TaskController = (function() {
    function TaskController($state, $scope, task, comments, Notifications, Template, Comments) {
      this.task = task;
      this.comments = comments;
      this.edit = function() {
        return this.task.isEdit = true;
      };
      this.destroyCb = (function(_this) {
        return function() {
          Notifications.success({
            text: 'Task deleted.'
          });
          return $state.go('taskboard.projects');
        };
      })(this);
      this.updateCb = (function(_this) {
        return function() {
          return Notifications.success({
            text: 'Task updated.'
          });
        };
      })(this);
      Comments.setComments(this.comments);
      Template.setTitle(this.task.title).setBodyClasses('single-task');
      $scope.$on('$destroy', function() {
        return Comments.setComments([]);
      });
    }

    return TaskController;

  })();

  angular.module('TodoApp').controller('TaskController', ['$state', '$scope', 'task', 'comments', 'Notifications', 'Template', 'Comments', TaskController]);

}).call(this);

(function() {
  'use strict';
  var TasksController;

  TasksController = (function() {
    function TasksController(TaskResource, Notifications) {
      this.newTask = new TaskResource();
      this.formatDeadline = function(task) {
        return moment(task.deadline).format('DD MMM YY');
      };
      this.isExpired = function(task) {
        return moment(task.deadline).valueOf() < moment().startOf('day').valueOf();
      };
      this.toggle = function(task) {
        return TaskResource.toggle({
          id: task.id
        }).$promise.then((function(_this) {
          return function(response) {
            return task.state = response.state;
          };
        })(this));
      };
      this.createTask = function(project) {
        if (this.form.$invalid) {
          return;
        }
        this.newTask.project_id = project.id;
        return this.newTask.$create().then((function(_this) {
          return function(task) {
            _this.form.$setPristine();
            _this.newTask = new TaskResource();
            project.tasks.push(task);
            return Notifications.success({
              text: 'Task created.'
            });
          };
        })(this));
      };
      this.dragAndDropCb = {
        orderChanged: (function(_this) {
          return function(event) {
            var task;
            task = event.dest.sortableScope.modelValue[event.dest.index];
            return TaskResource.update({
              id: task.id
            }, {
              position: event.dest.index + 1
            }).$promise.then(function(response) {
              return task.position = response.position;
            });
          };
        })(this)
      };
    }

    return TasksController;

  })();

  angular.module('TodoApp').controller('TasksController', ['TaskResource', 'Notifications', TasksController]);

}).call(this);

(function() {
  'use strict';
  var AppPreloadDirective;

  AppPreloadDirective = function($animate, $timeout) {
    var link;
    link = function(scope, el, attrs) {
      var removePreloader;
      removePreloader = function() {
        return $animate.leave(el.children()).then(function() {
          el.remove();
          return scope = el = attrs = null;
        });
      };
      return $timeout(removePreloader, 0);
    };
    return {
      restrict: 'A',
      link: link
    };
  };

  angular.module('TodoApp').directive('appPreload', ['$animate', '$timeout', AppPreloadDirective]);

}).call(this);

(function() {
  'use strict';
  var EditModeDirective;

  EditModeDirective = function() {
    var ctrl, lastScope, link;
    lastScope = null;
    ctrl = function($scope) {
      $scope.hasDeadline = $scope.model.hasOwnProperty('deadline');
      $scope.original = {
        title: $scope.model.title,
        deadline: $scope.model.deadline
      };
      $scope.needToUpdate = function() {
        var deadlineChanged, titleChanged;
        titleChanged = $scope.model.title !== $scope.original.title;
        deadlineChanged = $scope.model.deadline !== $scope.original.deadline;
        return titleChanged || deadlineChanged;
      };
      $scope.cancel = function(setOldValues) {
        if (setOldValues == null) {
          setOldValues = true;
        }
        if (setOldValues) {
          $scope.model.title = $scope.original.title;
          if ($scope.hasDeadline) {
            $scope.model.deadline = $scope.original.deadline;
          }
        }
        lastScope = null;
        return $scope.model.isEdit = false;
      };
      $scope.update = function(form) {
        if (form.$invalid) {
          return;
        }
        if (!$scope.needToUpdate()) {
          return $scope.cancel();
        }
        return $scope.model.$update().then((function(_this) {
          return function() {
            $scope.cancel(false);
            if ($scope.updateCb) {
              return $scope.updateCb($scope.model);
            }
          };
        })(this));
      };
      return $scope.destroy = function() {
        return $scope.model.$delete().then((function(_this) {
          return function() {
            $scope.cancel();
            if ($scope.destroyCb) {
              return $scope.destroyCb($scope.model);
            }
          };
        })(this));
      };
    };
    link = function(scope, el) {
      var keyUpHandler;
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
      templateUrl: 'templates/directives/edit_mode.html',
      replace: true,
      scope: {
        model: '=',
        destroyCb: '=',
        updateCb: '='
      },
      controller: ['$scope', ctrl],
      link: link
    };
  };

  angular.module('TodoApp').directive('editMode', [EditModeDirective]);

}).call(this);

(function() {
  'use strict';
  var FilesUploadDirective;

  FilesUploadDirective = function() {
    var ctrl, link;
    ctrl = function($scope) {
      return $scope.addFiles = function(files) {
        var file, i, len, results;
        results = [];
        for (i = 0, len = files.length; i < len; i++) {
          file = files[i];
          results.push($scope.files.push(file));
        }
        return results;
      };
    };
    link = function(scope, el) {
      var drop, input;
      drop = el.find('div');
      input = el.find('input');
      drop.on('dragover', function(ev) {
        ev.preventDefault();
        ev.stopPropagation();
        return el.addClass('dragover');
      });
      drop.on('dragleave', function(ev) {
        ev.preventDefault();
        ev.stopPropagation();
        return el.removeClass('dragover');
      });
      drop.on('drop', function(ev, hh) {
        var dataTransfer, files;
        ev.preventDefault();
        ev.stopPropagation();
        el.removeClass('dragover');
        dataTransfer = ev.dataTransfer ? ev.dataTransfer : ev.originalEvent.dataTransfer;
        files = dataTransfer.files;
        return scope.$apply(function() {
          return scope.addFiles(files);
        });
      });
      drop.on('click', function(ev) {
        return input[0].click();
      });
      return input.on('change', function(ev) {
        var files;
        ev.preventDefault();
        ev.stopPropagation();
        files = ev.target.files;
        return scope.$apply(function() {
          return scope.addFiles(files);
        });
      });
    };
    return {
      restrict: 'A',
      replace: true,
      scope: {
        files: '=filesUpload'
      },
      templateUrl: 'templates/directives/files_upload.html',
      controller: ['$scope', ctrl],
      link: link
    };
  };

  angular.module('TodoApp').directive('filesUpload', [FilesUploadDirective]);

}).call(this);

(function() {
  'use strict';
  var HasErrorsDirective;

  HasErrorsDirective = function() {
    var link;
    link = function(scope, el, attrs, form) {
      var handler, removeWatch, watchValue;
      watchValue = function() {
        return form[scope.field].$invalid && (form[scope.field].$dirty || form.$submitted);
      };
      handler = function(newValue) {
        if (newValue) {
          return el.addClass('has-error');
        } else {
          return el.removeClass('has-error');
        }
      };
      removeWatch = scope.$watch(watchValue, handler);
      return scope.$on('$destroy', function() {
        return removeWatch();
      });
    };
    return {
      restrict: 'A',
      link: link,
      require: '^form',
      scope: {
        field: '@hasErrors'
      }
    };
  };

  angular.module('TodoApp').directive('hasErrors', [HasErrorsDirective]);

}).call(this);

(function() {
  'use strict';
  var AttachmentResourceFactory;

  AttachmentResourceFactory = function($resource) {
    return $resource('/attachments/:id.json', {
      id: '@id'
    });
  };

  angular.module('TodoApp').factory('AttachmentResource', ['$resource', AttachmentResourceFactory]);

}).call(this);

(function() {
  'use strict';
  var CommentResourceFactory;

  CommentResourceFactory = function($resource) {
    var cleanResourceAttributes, createFormData;
    cleanResourceAttributes = function(data) {
      var cleanData, key, pattern, value;
      cleanData = {};
      pattern = /^\$.+|toJSON$/;
      for (key in data) {
        value = data[key];
        if (!pattern.test(key)) {
          cleanData[key] = data[key];
        }
      }
      return cleanData;
    };
    createFormData = function(data) {
      var formData, key, name, value;
      formData = new FormData();
      for (key in data) {
        value = data[key];
        if (key === 'attachments') {
          name = 'comment[attachments_attributes][][file]';
          data.attachments.forEach(function(file) {
            if (file instanceof File) {
              return formData.append(name, file, file.name);
            }
          });
        } else {
          formData.append("comment[" + key + "]", value);
        }
      }
      return formData;
    };
    return $resource('/comments/:id.json', {
      id: '@id'
    }, {
      update: {
        method: 'PUT',
        headers: {
          'Content-Type': void 0
        },
        transformRequest: [cleanResourceAttributes, createFormData]
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
          'Content-Type': void 0
        },
        transformRequest: [cleanResourceAttributes, createFormData]
      }
    });
  };

  angular.module('TodoApp').factory('CommentResource', ['$resource', CommentResourceFactory]);

}).call(this);

(function() {
  'use strict';
  var ProjectResourceFactory;

  ProjectResourceFactory = function($resource) {
    return $resource('/projects/:id.json', {
      id: '@id'
    }, {
      update: {
        method: 'PUT'
      }
    });
  };

  angular.module('TodoApp').factory('ProjectResource', ['$resource', ProjectResourceFactory]);

}).call(this);

(function() {
  'use strict';
  var TaskResourceFactory;

  TaskResourceFactory = function($resource) {
    var convertDeadlineFormat;
    convertDeadlineFormat = function(data) {
      if (data.deadline) {
        data.deadline = moment(data.deadline).format('DD-MM-YYYY');
      }
      return angular.toJson(data);
    };
    return $resource('/tasks/:id/:action.json', {
      id: '@id'
    }, {
      update: {
        method: 'PUT',
        transformRequest: [convertDeadlineFormat]
      },
      toggle: {
        method: 'PUT',
        params: {
          action: 'toggle'
        }
      },
      sort: {
        method: 'PUT',
        params: {
          action: 'sort'
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
        transformRequest: [convertDeadlineFormat]
      }
    });
  };

  angular.module('TodoApp').factory('TaskResource', ['$resource', TaskResourceFactory]);

}).call(this);

(function() {
  'use strict';
  var CommentsFactory;

  CommentsFactory = function($q) {
    var Factory, comments;
    Factory = {};
    comments = [];
    Factory.getComments = function() {
      return comments;
    };
    Factory.setComments = function(data) {
      return comments = data;
    };
    Factory.create = function(comment) {
      var deferred;
      deferred = $q.defer();
      comment.$create().then(function(response) {
        comments.push(response);
        return deferred.resolve(comments);
      });
      return deferred.promise;
    };
    Factory.destroy = function(comment) {
      var deferred;
      deferred = $q.defer();
      comment.$delete().then(function(response) {
        var index;
        index = comments.indexOf(comment);
        if (index > -1) {
          comments.splice(index, 1);
        }
        return deferred.resolve(comments);
      });
      return deferred.promise;
    };
    return Factory;
  };

  angular.module('TodoApp').factory('Comments', ['$q', CommentsFactory]);

}).call(this);

(function() {
  'use strict';
  var CsrfInterceptor;

  CsrfInterceptor = function() {
    var Interceptor, header;
    Interceptor = {};
    header = {
      name: 'X-CSRF-Token',
      value: 'csrf-token'
    };
    try {
      header.value = document.querySelector('meta[name="csrf-token"]').content;
    } catch (undefined) {}
    Interceptor.request = function(config) {
      if (config.method === 'GET') {
        return config;
      }
      config.headers = config.headers || {};
      config.headers[header.name] = header.value;
      return config;
    };
    return Interceptor;
  };

  angular.module('TodoApp').factory('CsrfInterceptor', [CsrfInterceptor]);

}).call(this);

(function() {
  'use strict';
  var ErrorHandlingInterceptor;

  ErrorHandlingInterceptor = function($q, Notifications) {
    var Interceptor;
    Interceptor = {};
    Interceptor.responseError = function(err) {
      if (err.data.messages && err.data.messages.length) {
        err.data.messages.forEach(function(m) {
          return Notifications.error({
            text: m
          });
        });
      } else if (err.data.details) {
        Notifications.error({
          text: err.data.details
        });
      } else if (err.data.errors && err.data.errors.length) {
        err.data.errors.forEach(function(e) {
          return Notifications.error({
            text: e
          });
        });
      } else if (err.data.errors && err.data.errors.full_messages) {
        err.data.errors.full_messages.forEach(function(e) {
          return Notifications.error({
            text: e
          });
        });
      } else {
        Notifications.error();
      }
      return $q.reject(err);
    };
    return Interceptor;
  };

  angular.module('TodoApp').factory('ErrorHandlingInterceptor', ['$q', 'Notifications', ErrorHandlingInterceptor]);

}).call(this);

(function() {
  'use strict';
  var NotificationsFactory;

  NotificationsFactory = function($timeout) {
    var Notifications, add, current, defaults, queue, remove;
    Notifications = {};
    defaults = {
      limit: 4,
      success: {
        title: 'Success',
        text: 'Action performed successfully.',
        time: 4500
      },
      error: {
        title: 'Error',
        text: 'Oops, something went wrong.',
        time: 4500
      }
    };
    current = [];
    queue = [];
    add = function(opt) {
      var notification;
      if (current.length >= defaults.limit) {
        return queue.push(opt);
      }
      notification = angular.extend({}, defaults[opt.type], opt);
      current.push(notification);
      return notification.timeout = $timeout(remove.bind(null, notification), notification.time);
    };
    remove = function(notification) {
      var index;
      if (!notification) {
        return;
      }
      index = current.indexOf(notification);
      if (notification.timeout) {
        $timeout.cancel(notification.timeout);
      }
      current.splice(index, 1);
      if (queue.length) {
        notification = queue.shift();
        return add(notification);
      }
    };
    Notifications.getCurrent = function() {
      return current;
    };
    Notifications.success = function(opt) {
      if (opt == null) {
        opt = {};
      }
      opt.type = 'success';
      return add(opt);
    };
    Notifications.error = function(opt) {
      if (opt == null) {
        opt = {};
      }
      opt.type = 'error';
      return add(opt);
    };
    Notifications.remove = function(notification) {
      return remove(notification);
    };
    return Notifications;
  };

  angular.module('TodoApp').factory('Notifications', ['$timeout', NotificationsFactory]);

}).call(this);

(function() {
  'use strict';
  var ProgressInterceptor;

  ProgressInterceptor = function(ngProgressFactory, $q) {
    var Interceptor, progress, templateUrlPattern;
    Interceptor = {};
    progress = null;
    templateUrlPattern = /^templates?\//;
    Interceptor.request = function(config) {
      if (templateUrlPattern.test(config.url)) {
        return config;
      }
      if (progress == null) {
        progress = ngProgressFactory.createInstance();
      }
      progress.setColor('#678cf3');
      progress.start();
      return config;
    };
    Interceptor.response = function(response) {
      if (templateUrlPattern.test(response.config.url)) {
        return response;
      }
      progress.complete();
      return response;
    };
    Interceptor.requestError = function(err) {
      progress.complete();
      return $q.reject(err);
    };
    Interceptor.responseError = function(err) {
      progress.complete();
      return $q.reject(err);
    };
    return Interceptor;
  };

  angular.module('TodoApp').factory('ProgressInterceptor', ['ngProgressFactory', '$q', ProgressInterceptor]);

}).call(this);

(function() {
  'use strict';
  var ProjectsFactory;

  ProjectsFactory = function($q, $modal, $rootScope) {
    var Factory, projects;
    Factory = {};
    projects = null;
    Factory.getProjects = function() {
      return projects || [];
    };
    Factory.setProjects = function(data) {
      return projects = data;
    };
    Factory.newProjectModal = function() {
      var deferred;
      deferred = $q.defer();
      $modal.open({
        templateUrl: 'templates/modals/new_project.html',
        controller: 'NewProjectModalController',
        controllerAs: 'modalCtrl'
      }).result.then(function(project) {
        if (!projects) {
          Factory.setProjects([]);
        }
        projects.push(project);
        return deferred.resolve(project);
      })["catch"](function(err) {
        return deferred.reject(err);
      });
      return deferred.promise;
    };
    return Factory;
  };

  angular.module('TodoApp').factory('Projects', ['$q', '$modal', '$rootScope', ProjectsFactory]);

}).call(this);

(function() {
  'use strict';
  var TemplateFactory;

  TemplateFactory = function() {
    var Template, bodyClasses, title;
    Template = {};
    title = '';
    bodyClasses = '';
    Template.getTitle = function() {
      if (title) {
        return title + " - Todo";
      } else {
        return 'Todo';
      }
    };
    Template.setTitle = function(newTitle) {
      title = newTitle;
      return Template;
    };
    Template.getBodyClasses = function() {
      return bodyClasses;
    };
    Template.setBodyClasses = function(newBodyClasses) {
      bodyClasses = newBodyClasses;
      return Template;
    };
    return Template;
  };

  angular.module('TodoApp').factory('Template', [TemplateFactory]);

}).call(this);

angular.module("TodoApp").run(["$templateCache", function($templateCache) {$templateCache.put("templates/auth.html","<div class=\"auth-forms\">\n    <div class=\"brand\">\n        Todo\n    </div>\n\n    <form ng-submit=\"authCtrl.login()\" role=\"form\" class=\"login-form\" name=\"authCtrl.loginForm\" novalidate>\n        <div class=\"form-group\" has-errors=\"email\">\n            <label>Email</label>\n            <input type=\"email\" name=\"email\" ng-model=\"authCtrl.loginData.email\" required=\"required\" class=\"form-control\"/>\n\n            <ng-messages ng-if=\"authCtrl.loginForm.$submitted || authCtrl.loginForm.email.$dirty\" for=\"authCtrl.loginForm.email.$error\">\n                <p ng-message=\"required\" class=\"help-block\">\n                    Email is required\n                </p>\n\n                <p ng-message=\"email\" class=\"help-block\">\n                    Email has wrong format\n                </p>\n            </ng-messages>\n        </div>\n\n        <div class=\"form-group\" has-errors=\"password\">\n            <label>Password</label>\n            <input type=\"password\" name=\"password\" ng-model=\"authCtrl.loginData.password\" required=\"required\" class=\"form-control\"/>\n\n            <ng-messages ng-if=\"authCtrl.loginForm.$submitted || authCtrl.loginForm.password.$dirty\" for=\"authCtrl.loginForm.password.$error\">\n                <p ng-message=\"required\" class=\"help-block\">\n                    Password is required\n                </p>\n            </ng-messages>\n        </div>\n\n        <button type=\"submit\" class=\"btn btn-primary btn-block\">\n            Sign in\n        </button>\n\n        <a ng-click=\"authCtrl.facebook()\" class=\"btn btn-primary btn-block\">\n            Enter via Facebook\n        </a>\n    </form>\n\n    <div class=\"or\">\n        <span>or</span>\n    </div>\n\n    <form ng-submit=\"authCtrl.register()\" role=\"form\" class=\"register-form\" novalidate name=\"authCtrl.regForm\">\n        <div class=\"form-group\" has-errors=\"first_name\">\n            <label>First name</label>\n            <input type=\"text\" name=\"first_name\" ng-model=\"authCtrl.registerData.first_name\" required=\"required\" class=\"form-control\"/>\n\n            <ng-messages ng-if=\"authCtrl.regForm.$submitted || authCtrl.regForm.first_name.$dirty\" for=\"authCtrl.regForm.first_name.$error\">\n                <p ng-message=\"required\" class=\"help-block\">\n                    First name is required\n                </p>\n            </ng-messages>\n        </div>\n\n        <div class=\"form-group\" has-errors=\"last_name\">\n            <label>Last name</label>\n            <input type=\"text\" name=\"last_name\" ng-model=\"authCtrl.registerData.last_name\" required=\"required\" class=\"form-control\"/>\n\n            <ng-messages ng-if=\"authCtrl.regForm.$submitted || authCtrl.regForm.last_name.$dirty\" for=\"authCtrl.regForm.last_name.$error\">\n                <p ng-message=\"required\" class=\"help-block\">\n                    Last name is required\n                </p>\n            </ng-messages>\n        </div>\n\n        <div class=\"form-group\" has-errors=\"email\">\n            <label>Email</label>\n            <input type=\"email\" name=\"email\" ng-model=\"authCtrl.registerData.email\" required=\"required\" class=\"form-control\"/>\n\n            <ng-messages ng-if=\"authCtrl.regForm.$submitted || authCtrl.regForm.email.$dirty\" for=\"authCtrl.regForm.email.$error\">\n                <p ng-message=\"required\" class=\"help-block\">\n                    Email is required\n                </p>\n\n                <p ng-message=\"email\" class=\"help-block\">\n                    Email has wrong format\n                </p>\n            </ng-messages>\n        </div>\n\n        <div class=\"form-group\" has-errors=\"password\">\n            <label>Password</label>\n            <input type=\"password\" name=\"password\" ng-model=\"authCtrl.registerData.password\" required=\"required\" class=\"form-control\"/>\n\n            <ng-messages ng-if=\"authCtrl.regForm.$submitted || authCtrl.regForm.password.$dirty\" for=\"authCtrl.regForm.password.$error\">\n                <p ng-message=\"required\" class=\"help-block\">\n                    Password is required\n                </p>\n            </ng-messages>\n        </div>\n\n        <div class=\"form-group\" has-errors=\"password_confirmation\">\n            <label>Password confirmation</label>\n            <input type=\"password\" name=\"password_confirmation\" ng-model=\"authCtrl.registerData.password_confirmation\" required=\"required\" class=\"form-control\"/>\n\n            <ng-messages ng-if=\"authCtrl.regForm.$submitted || authCtrl.regForm.password_confirmation.$dirty\" for=\"authCtrl.regForm.password_confirmation.$error\">\n                <p ng-message=\"required\" class=\"help-block\">\n                    Password confirmation is required\n                </p>\n            </ng-messages>\n        </div>\n\n        <button type=\"submit\" class=\"btn btn-primary btn-block\">Register</button>\n\n        <a ng-click=\"authCtrl.facebook()\" class=\"btn btn-primary btn-block\">\n            Enter via Facebook\n        </a>\n    </form>\n</div>");
$templateCache.put("templates/projects.html","<div class=\"container dashboard\">\n    <div ng-repeat=\"project in projectsCtrl.projects\">\n        <div class=\"main card\">\n            <div class=\"not-edit\" ng-if=\"!project.isEdit\">\n                <div class=\"title\">{{ project.title }}</div>\n\n                <span ng-click=\"projectsCtrl.edit(project)\" class=\"edit-button\">\n                    <i class=\"fa fa-pencil-square-o\"></i>\n                </span>\n            </div>\n\n            <div class=\"edit\" ng-if=\"project.isEdit\">\n                <edit-mode model=\"project\" destroy-cb=\"projectsCtrl.destroyCb\" update-cb=\"projectsCtrl.updateCb\">\n                </edit-mode>\n            </div>\n        </div>\n\n        <div ng-controller=\"TasksController as tasksCtrl\">\n            <div class=\"tasks card\" ng-model=\"project.tasks\" as-sortable=\"tasksCtrl.dragAndDropCb\">\n                <div ng-repeat=\"task in project.tasks\" class=\"task clearfix {{ task.state }}\" as-sortable-item>\n                    <div class=\"not-edit\" as-sortable-item-handle>\n\n                        <div class=\"task-state\">\n                            <div class=\"custom-checkbox\" ng-click=\"tasksCtrl.toggle(task)\">\n                            </div>\n                        </div>\n\n                        <div class=\"task-title\">\n                            {{ task.title }}\n                        </div>\n\n                        <div ng-if=\"task.deadline\" class=\"task-deadline\" ng-class=\"{\'expired\': tasksCtrl.isExpired(task)}\">\n                            {{ tasksCtrl.formatDeadline(task) }}\n                        </div>\n\n                        <div class=\"task-link\" ui-sref=\"taskboard.task({id: task.id})\">\n                        </div>\n                    </div>\n                </div>\n            </div>\n\n            <div class=\"card add-task\">\n                <form novalidate name=\"tasksCtrl.form\" ng-submit=\"tasksCtrl.createTask(project)\">\n                    <div class=\"add-deadline\">\n                        <a ng-click=\"open = !open\"\n                           datepicker-popup=\"yyyy-MM-dd\"\n                           ng-model=\"tasksCtrl.newTask.deadline\"\n                           is-open=\"open\"\n                           show-button-bar=\"false\">\n                            {{ tasksCtrl.newTask.deadline ? \'Edit deadline\' : \'Add deadline\' }}\n                        </a>\n                    </div>\n\n                    <div class=\"form-group\" has-errors=\"title\">\n                        <label>New task</label>\n\n                        <input type=\"text\" name=\"title\" class=\"form-control\" ng-model=\"tasksCtrl.newTask.title\" required />\n\n                        <ng-messages ng-if=\"tasksCtrl.form.$submitted || tasksCtrl.form.title.$dirty\" for=\"tasksCtrl.form.title.$error\">\n                            <p ng-message=\"required\" class=\"help-block\">\n                                Title is required\n                            </p>\n                        </ng-messages>\n                    </div>\n\n                    <button class=\"btn btn-primary\" type=\"submit\" ng-disabled=\"tasksCtrl.form.$invalid\">\n                        Add new task\n                    </button>\n                </form>\n            </div>\n        </div>\n\n        <hr ng-if=\"!$last\" class=\"projects-separator\" />\n    </div>\n\n    <div class=\"empty card\" ng-if=\"!projectsCtrl.projects.length\">\n        <div class=\"empty-image\">\n            <img src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGYAAABmCAYAAAA53+RiAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyNpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDE0IDc5LjE1MTQ4MSwgMjAxMy8wMy8xMy0xMjowOToxNSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6QzA0MjM0MDRDNkIyMTFFNEIxODRDNjhFNkY1QzNGNEEiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6QzA0MjM0MDNDNkIyMTFFNEIxODRDNjhFNkY1QzNGNEEiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIChNYWNpbnRvc2gpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MjU5MTEzODNCQjUwMTFFNDkzQzhBNUYwOTFBMDQ0MEYiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6MjU5MTEzODRCQjUwMTFFNDkzQzhBNUYwOTFBMDQ0MEYiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz7xPgVYAAAN60lEQVR42uxdCZQU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\"/>\n        </div>\n\n        <p class=\"text\">\n            You weren\'t have created any projects yet, but it\'s good that it\'s easy to fix ;)\n        </p>\n\n        <p class=\"text\">\n            Just select <b>\"Create new project\"</b> from user menu\n        </p>\n    </div>\n</div>");
$templateCache.put("templates/task.html","<div class=\"dashboard\">\n    <div class=\"back-button-wrap\">\n        <div class=\"back-button\" ui-sref=\"taskboard.projects\">\n            back to projects\n        </div>\n    </div>\n\n    <div class=\"main task-card card\">\n        <div class=\"not-edit\" ng-if=\"!taskCtrl.task.isEdit\">\n            <div class=\"title\">{{ taskCtrl.task.title }}</div>\n\n            <span ng-click=\"taskCtrl.edit()\" class=\"edit-button\">\n                <i class=\"fa fa-pencil-square-o\"></i>\n            </span>\n        </div>\n\n        <div class=\"edit\" ng-if=\"taskCtrl.task.isEdit\">\n            <edit-mode model=\"taskCtrl.task\" destroy-cb=\"taskCtrl.destroyCb\" update-cb=\"taskCtrl.updateCb\">\n            </edit-mode>\n        </div>\n    </div>\n\n    <div ng-controller=\"CommentsController as commentsCtrl\">\n        <div class=\"comments card\">\n            <div class=\"comment\" ng-repeat=\"comment in commentsCtrl.comments\" ng-if=\"!comment.isEdit\">\n                <div class=\"comment-created\">\n                    <i class=\"fa fa-clock-o\"></i> {{ commentsCtrl.formatUpdated(comment) }}\n                </div>\n\n                <div class=\"comment-note\">\n                    {{ comment.note }}\n                </div>\n\n                <div class=\"controls\">\n                    <span class=\"edit-comment\" ng-click=\"commentsCtrl.edit(comment)\">\n                        <i class=\"fa fa-pencil\"></i>\n                    </span>\n\n                    <span class=\"destroy-comment\" ng-click=\"commentsCtrl.destroy(comment)\">\n                        <i class=\"fa fa-times\"></i>\n                    </span>\n                </div>\n\n                <div class=\"comment-attachments\">\n                    <div class=\"attachment\" ng-repeat=\"a in comment.attachments\">\n                        <a href=\"{{ a.file.url }}\" target=\"_blank\">{{a.file.name}}</a>\n                    </div>\n                </div>\n            </div>\n        </div>\n\n        <div class=\"card add-comment\">\n            <form novalidate name=\"commentsCtrl.form\" ng-submit=\"commentsCtrl.submit(taskCtrl.task)\">\n                <div files-upload=\"commentsCtrl.newComment.attachments\"></div>\n\n                <ul class=\"uploaded-attachments list-unstyled\">\n                    <li ng-repeat=\"a in commentsCtrl.newComment.attachments\">\n                        <a ng-if=\"a.id\" href=\"{{ a.file.url }}\" target=\"_blank\">\n                            {{a.file.name}}\n                        </a>\n\n                        <span ng-if=\"!a.id\">\n                            {{ a.name }}\n                        </span>\n\n                        <span class=\"remove-attachment\" ng-click=\"commentsCtrl.removeAttachment(a)\">\n                            <i class=\"fa fa-trash-o\"></i>\n                        </span>\n                    </li>\n                </ul>\n\n                <div class=\"form-group\" has-errors=\"note\">\n                    <label>Comment</label>\n\n                    <textarea class=\"form-control\" ng-model=\"commentsCtrl.newComment.note\" name=\"note\" required></textarea>\n\n                    <ng-messages ng-if=\"commentsCtrl.form.$submitted || commentsCtrl.form.note.$dirty\" for=\"commentsCtrl.form.note.$error\">\n                        <p ng-message=\"required\" class=\"help-block\">\n                            Note is required\n                        </p>\n                    </ng-messages>\n                </div>\n\n                <button class=\"btn btn-primary\" type=\"submit\">\n                    {{ commentsCtrl.newComment.id ? \'Edit comment\' : \'Add comment\' }}\n                </button>\n\n                <a ng-if=\"commentsCtrl.newComment.id\" ng-click=\"commentsCtrl.cancel()\" class=\"btn btn-warning\">\n                    Cancel\n                </a>\n            </form>\n        </div>\n    </div>\n</div>");
$templateCache.put("templates/taskboard.html","<header ng-controller=\"HeaderController as headerCtrl\">\n    <nav class=\"navbar navbar-inverse navbar-default navbar-fixed-top\">\n        <div class=\"container\">\n            <div class=\"navbar-header\">\n                <a class=\"navbar-brand\" ui-sref=\"taskboard.projects\">Todo</a>\n            </div>\n\n            <div class=\"navbar-right\" ng-if=\"headerCtrl.user.signedIn\">\n                <div dropdown>\n                    <div class=\"avatar\" dropdown-toggle>\n                        <img ng-src=\"{{ headerCtrl.user.image.url }}\">\n                    </div>\n\n                    <ul class=\"dropdown-menu dropdown-menu-right\" role=\"menu\">\n                        <li>\n                            <a ui-sref=\"taskboard.projects\">\n                                My projects\n                            </a>\n                        </li>\n                        <li role=\"presentation\" class=\"divider\"></li>\n                        <li>\n                            <a ng-click=\"headerCtrl.createProject()\">\n                                Create new project\n                            </a>\n                        </li>\n                        <li role=\"presentation\" class=\"divider\"></li>\n                        <li>\n                            <a ng-click=\"headerCtrl.signOut()\">\n                                Sign out\n                            </a>\n                        </li>\n                    </ul>\n                </div>\n            </div>\n        </div>\n    </nav>\n</header>\n\n<ui-view></ui-view>");
$templateCache.put("templates/directives/edit_mode.html","<div>\n    <form role=\"form\" name=\"form\" ng-submit=\"update(this.form)\" novalidate>\n        <div class=\"form-group\" has-errors=\"title\">\n            <input type=\"text\" name=\"title\" ng-model=\"model.title\" required class=\"form-control\" />\n        </div>\n    </form>\n\n    <div class=\"controls\">\n        <span ng-click=\"update(this.form)\">\n            <i class=\"fa fa-check\"></i>\n        </span>\n\n        <span ng-if=\"hasDeadline\"\n              ng-click=\"open = !open\"\n              datepicker-popup=\"yyyy-MM-dd\"\n              ng-model=\"model.deadline\"\n              is-open=\"open\"\n              show-button-bar=\"false\">\n            <i class=\"fa fa-calendar\"></i>\n        </span>\n\n        <span ng-click=\"cancel()\">\n            <i class=\"fa fa-times\"></i>\n        </span>\n\n        <span ng-click=\"destroy()\">\n            <i class=\"fa fa-trash-o\"></i>\n        </span>\n    </div>\n</div>");
$templateCache.put("templates/directives/files_upload.html","<div class=\"files-upload\">\n    <div class=\"drop-area\">\n    	<span>Drop your files here, or just click me...</span>\n    </div>\n    <input type=\"file\" multiple />\n</div>");
$templateCache.put("templates/modals/new_project.html","<div class=\"modal-header\">\n    <h3 class=\"modal-title\">\n        Create project\n    </h3>\n</div>\n\n<div class=\"modal-body\">\n    <form role=\"form\" name=\"modalCtrl.form\" novalidate ng-submit=\"modalCtrl.submit()\">\n        <div class=\"form-group\" has-errors=\"title\">\n            <label>Project title</label>\n\n            <input type=\"text\" name=\"title\" ng-model=\"modalCtrl.project.title\" required autofocus class=\"form-control\"/>\n\n            <ng-messages ng-if=\"modalCtrl.form.$submitted || modalCtrl.form.title.$dirty\" for=\"modalCtrl.form.title.$error\">\n                <p ng-message=\"required\" class=\"help-block\">\n                    Title is required\n                </p>\n            </ng-messages>\n        </div>\n    </form>\n</div>\n\n<div class=\"modal-footer\">\n    <button class=\"btn btn-primary\" type=\"button\" ng-click=\"modalCtrl.submit()\" ng-disabled=\"modalCtrl.form.$invalid\">\n        Create\n    </button>\n\n    <button class=\"btn btn-warning\" type=\"button\" ng-click=\"modalCtrl.cancel()\">\n        Cancel\n    </button>\n</div>\n");}]);