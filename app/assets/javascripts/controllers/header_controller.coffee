class HeaderController
  constructor: ($auth, $rootScope, $modal) ->
    @user = $rootScope.user || {}
    @signOut = $auth.signOut.bind($auth)
    @isMenuOpen = false

    @create_project = () ->
      modal = $modal.open(
        templateUrl: 'modals/create_project.html',
        controller: 'ProjectModalController'
        controllerAs: 'pmc'
      )

      modal
        .result
        .then((project) ->
          $rootScope.$broadcast('projects:new_project', project)
        )

angular
  .module('TodoApp')
  .controller('HeaderController', [
    '$auth',
    '$rootScope',
    '$modal',
    HeaderController
  ])