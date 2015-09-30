describe 'Notifications', () ->
  Notifications = null

  injectorFn = (_Notifications_) ->
    Notifications = _Notifications_

  beforeEach(module('TodoApp'))
  beforeEach(inject(injectorFn))

  describe '.getCurrent', () ->
    it 'expect to return empty array, if notifications empty', () ->
      expect(Notifications.getCurrent().length).to.equal(0)

    it 'expect to return notifications array', () ->
      Notifications.success()
      expect(Notifications.getCurrent().length).to.equal(1)

  describe '.success', () ->
    it 'expect to add notification', () ->
      Notifications.success()
      expect(Notifications.getCurrent().length).to.equal(1)

    it 'expect to add notification, with success type', () ->
      Notifications.success()
      expect(Notifications.getCurrent()[0].type).to.equal('success')

  describe '.error', () ->
    it 'expect to add notification', () ->
      Notifications.error()
      expect(Notifications.getCurrent().length).to.equal(1)

    it 'expect to add notification, with error type', () ->
      Notifications.error()
      expect(Notifications.getCurrent()[0].type).to.equal('error')

  describe '.remove', () ->
    it 'expect to remove notification', () ->
      Notifications.error()
      Notifications.remove(Notifications.getCurrent()[0])
      expect(Notifications.getCurrent().length).to.equal(0)
