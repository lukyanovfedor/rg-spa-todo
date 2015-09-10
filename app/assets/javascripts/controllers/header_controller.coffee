class HeaderController
  constructor: ($auth, $rootScope, $modal, $state) ->
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
        .then((project) -> $state.go('taskboard.project', id: project.id))

angular
  .module('TodoApp')
  .controller('HeaderController', [
    '$auth',
    '$rootScope',
    '$modal',
    '$state',
    HeaderController
  ])