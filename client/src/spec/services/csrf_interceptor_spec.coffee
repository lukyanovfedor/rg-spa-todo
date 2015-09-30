describe 'CsrfInterceptor', () ->
  CsrfInterceptor = null
  config = {}

  injectorFn = (_CsrfInterceptor_) ->
    CsrfInterceptor = _CsrfInterceptor_

  beforeEach(module('TodoApp'))
  beforeEach(inject(injectorFn))

  describe '.request', () ->
    it 'expect to have handler for request', () ->
      expect(angular.isFunction(CsrfInterceptor.request)).to.equal(true)

    it 'expect not to set header, if config method GET', () ->
      config.method = 'GET'
      afterRequest = CsrfInterceptor.request(config)
      expect(afterRequest.headers).to.equal(undefined)

    it 'expect to set header', () ->
      config.method = 'POST'
      afterRequest = CsrfInterceptor.request(config)
      expect(Object.keys(afterRequest.headers).length).to.equal(1)
