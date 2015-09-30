describe 'appPreload', () ->
  element = null
  $scope = null
  $q = null

  MockAnimate = {}

  injectFn = (_$rootScope_, _$compile_, _$q_, _$timeout_) ->
    $scope = _$rootScope_.$new()
    $q = _$q_

    simple.mock(MockAnimate, 'leave').returnWith( $q.when() )

    element = [
      '<div class="app-loading" ng-animate-children app-preload>',
        '<div id="loader"></div>',
      '</div>'
    ].join('')

    element = _$compile_(element)($scope)
    document.body.appendChild(element[0])

    _$timeout_.flush()
    $scope.$digest()

  beforeEach(module('TodoApp'))

  beforeEach(module(($provide) ->
    $provide.service('$animate', () ->
      MockAnimate
    )

    return undefined
  ))

  beforeEach () ->
    inject(injectFn)

  it 'expect to receive $animate leave', () ->
    expect(MockAnimate.leave.called).to.be.true

  it 'expect remove element from dom', () ->
    expect(document.body.querySelector('.app-loading')).to.equal(null)

