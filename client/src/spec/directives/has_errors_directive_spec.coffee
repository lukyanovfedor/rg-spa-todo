describe 'HasErrorsDirective', () ->
  $scope = null
  element = null
  form = null


  injectFn = (_$compile_, _$rootScope_) ->
    $scope = _$rootScope_
    $scope.model =
      title: ''

    element = [
      '<form name="form">',
        '<div has-errors="title">',
          '<input ng-model="model.title" name="title" required />',
        '</div>'
      '</form>'
    ].join('')

    element = _$compile_(element)($scope)
    form = $scope.form

  beforeEach(module('TodoApp'))
  beforeEach(inject(injectFn))

  it 'expect to add has-error class to element if form field invalid', () ->
    form.title.$setViewValue('')
    $scope.$digest()
    expect(element.find('div').hasClass('has-error')).to.be.true

  it 'expect to remove has-error class from element if form field valid', () ->
    form.title.$setViewValue('yoyo')
    $scope.$digest()
    expect(element.find('div').hasClass('has-error')).to.be.false
