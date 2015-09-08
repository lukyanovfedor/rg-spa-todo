class HeaderController
  constructor: ($auth, $rootScope) ->
    @user = $rootScope.user || {}
    @signOut = $auth.signOut.bind($auth)
    @isMenuOpen = false

angular
  .module('TodoApp')
  .controller('HeaderController', [
    '$auth',
    '$rootScope',
    HeaderController
  ])