describe 'ProgressInterceptor', () ->
  ProgressInterceptor = null
  MockProgressFactory = {}
  progress = {}
  config = {}

  injectorFn = (_ProgressInterceptor_) ->
    ProgressInterceptor = _ProgressInterceptor_

  beforeEach(module('TodoApp'))

  beforeEach(module(($provide) ->
    $provide.factory('ngProgressFactory', () ->
      MockProgressFactory
    )

    return undefined
  ))

  beforeEach(() ->
    simple.mock(MockProgressFactory, 'createInstance').returnWith(progress)
    simple.mock(progress, 'setColor')
    simple.mock(progress, 'start')
    simple.mock(progress, 'complete')

    inject(injectorFn)
  )

  afterEach(() ->
    config = {}
  )

  describe '.request', () ->
    it 'expect to have handler for request', () ->
      expect(angular.isFunction(ProgressInterceptor.request)).to.equal(true)

    it 'expect to receive createInstance', () ->
      ProgressInterceptor.request(config)
      expect(MockProgressFactory.createInstance.called).to.equal(true)

    it 'expect to receive setColor', () ->
      ProgressInterceptor.request(config)
      expect(progress.setColor.called).to.equal(true)

    it 'expect to receive start', () ->
      ProgressInterceptor.request(config)
      expect(progress.start.called).to.equal(true)

    it 'expect to return, if url is start with "templates', () ->
      config.url = 'templates/yoyoy.html'
      ProgressInterceptor.request(config)
      expect(MockProgressFactory.createInstance.called).to.equal(false)

  describe '.response', () ->
    it 'expect to have handler for response', () ->
      expect(angular.isFunction(ProgressInterceptor.response)).to.equal(true)

    it 'expect to receive complete', () ->
      ProgressInterceptor.request(config)
      config = { config: {} }
      ProgressInterceptor.response(config)
      expect(progress.complete.called).to.equal(true)

    it 'expect to return, if url is start with "templates', () ->
      ProgressInterceptor.request(config)
      config = { config: { url: 'templates/yoyoy.html' } }
      ProgressInterceptor.response(config)
      expect(progress.complete.called).to.equal(false)

  describe '.requestError', () ->
    it 'expect to have handler for requestError', () ->
      expect(angular.isFunction(ProgressInterceptor.requestError)).to.equal(true)

    it 'expect to receive complete', () ->
      ProgressInterceptor.request(config)
      ProgressInterceptor.requestError()
      expect(progress.complete.called).to.equal(true)

  describe '.responseError', () ->
    it 'expect to have handler for responseError', () ->
      expect(angular.isFunction(ProgressInterceptor.responseError)).to.equal(true)

    it 'expect to receive complete', () ->
      ProgressInterceptor.request(config)
      ProgressInterceptor.responseError()
      expect(progress.complete.called).to.equal(true)
