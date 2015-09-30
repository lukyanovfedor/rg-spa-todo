describe 'ErrorHandlingInterceptor', () ->
  ErrorHandlingInterceptor = null
  MockNotifications = {}
  config = null

  injectorFn = (_ErrorHandlingInterceptor_) ->
    ErrorHandlingInterceptor = _ErrorHandlingInterceptor_

    config = {data: {}}

  beforeEach(module('TodoApp'))

  beforeEach(module(($provide) ->
    $provide.factory('Notifications', () ->
      MockNotifications
    )

    return undefined
  ))

  beforeEach () ->
    simple.mock(MockNotifications, 'error')

    inject(injectorFn)

  it 'expect to have handler for responseError', () ->
    expect(ErrorHandlingInterceptor.responseError).to.be.an.instanceof(Function)

  it 'expect to receive error for Notifications if config.data.messages.length', () ->
    config.data.messages = ['first', 'seccond']
    ErrorHandlingInterceptor.responseError(config)
    expect(MockNotifications.error.callCount).to.equal(2)

  it 'expect to receive error for Notifications if config.data.details', () ->
    config.data.details = 'some exception'
    ErrorHandlingInterceptor.responseError(config)
    expect(MockNotifications.error.called).to.be.true

  it 'expect to receive error for Notifications if config.data.errors.length', () ->
    config.data.errors = ['first', 'seccond']
    ErrorHandlingInterceptor.responseError(config)
    expect(MockNotifications.error.callCount).to.equal(2)

  it 'expect to receive error for Notifications', () ->
    ErrorHandlingInterceptor.responseError(config)
    expect(MockNotifications.error.called).to.be.true