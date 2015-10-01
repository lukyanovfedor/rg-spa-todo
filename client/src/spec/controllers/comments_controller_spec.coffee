describe 'CommentsController', () ->
  $scope = null
  $httpBackend = null

  MockComments = {}
  MockNotifications = {}

  injectorFn = (_$rootScope_, _$controller_, _$q_, _$httpBackend_) ->
    $scope = _$rootScope_.$new()
    $httpBackend = _$httpBackend_
    simple.Promise = _$q_

    _$controller_('CommentsController as commentsCtrl', { $scope: $scope })

  beforeEach(module('TodoApp'))

  beforeEach(module(($provide) ->
    $provide.factory('Comments', () ->
      MockComments
    )

    $provide.factory('Notifications', () ->
      MockNotifications
    )

    return undefined
  ))

  beforeEach(() ->
    simple.mock(MockComments, 'getComments').returnWith([])
    simple.mock(MockNotifications, 'success')

    inject(injectorFn)

    $scope.commentsCtrl.form =
      $setPristine: () ->
  )

  it 'expect to assign newComment', () ->
    expect($scope.commentsCtrl.newComment).to.exist

  describe '.comments', () ->
    it 'expect to receive getComments for Comments', () ->
      expect(MockComments.getComments.called).to.be.true

    it 'expect to assign comments', () ->
      expect($scope.commentsCtrl.comments).to.exist

  describe '.formatUpdated', () ->
    it 'expect to assign formatUpdated', () ->
      expect($scope.commentsCtrl.formatUpdated).to.be.an.instanceof(Function)

    it 'expect to return date in format "h:mma MMMM Do YYYY"', () ->
      comment = { updated_at: '2015-09-28 17:46:21' }
      expect($scope.commentsCtrl.formatUpdated(comment)).to.equal('5:46pm September 28th 2015')

  describe '.edit', () ->
    it 'expect to assign edit function', () ->
      expect($scope.commentsCtrl.edit).to.be.an.instanceof(Function)

    it 'expect to set isEdit = true', () ->
      comment = {}
      $scope.commentsCtrl.edit(comment)
      expect(comment.isEdit).to.be.true

  describe '.destroy', () ->
    beforeEach () ->
      simple.mock(MockComments, 'destroy').resolveWith()

    it 'expect to assign destroy function', () ->
      expect($scope.commentsCtrl.destroy).to.be.an.instanceof(Function)

    it 'expect to receive destroy for Comments', () ->
      comment = {}
      $scope.commentsCtrl.destroy(comment)
      expect(MockComments.destroy.lastCall.arg).to.equal(comment)

    it 'expect to receive success for Notifications, after destroy', () ->
      comment = {}
      $scope.commentsCtrl.destroy(comment)
      $scope.$digest()
      expect(MockNotifications.success.called).to.be.true

  describe '.submit', () ->
    it 'expect to assign submit function', () ->
      expect($scope.commentsCtrl.submit).to.be.an.instanceof(Function)

    describe 'newComment has id', () ->
      beforeEach () ->
        $scope.commentsCtrl.newComment.id = 1

      it 'expect to receive success for Notifications, after update', () ->
        $httpBackend.expectPUT('/comments/1.json').respond(200)
        $scope.commentsCtrl.submit()
        $httpBackend.flush()
        expect(MockNotifications.success.called).to.be.true

    describe 'newComment without id', () ->
      beforeEach () ->
        simple.mock(MockComments, 'create').resolveWith()

      it 'expect to set task_id to newComment', () ->
        task = { id: 1 }
        $scope.commentsCtrl.submit(task)
        expect($scope.commentsCtrl.newComment.task_id).to.equal(1)

      it 'expect to receive create for Comments', () ->
        task = { id: 1 }
        $scope.commentsCtrl.submit(task)
        expect(MockComments.create.lastCall.arg).to.equal($scope.commentsCtrl.newComment)

      it 'expect to receive success for Notifications, after creation', () ->
        task = { id: 1 }
        $scope.commentsCtrl.submit(task)
        $scope.$digest()
        expect(MockNotifications.success.called).to.be.true

    describe '.removeAttachment', () ->
      it 'expect to assign removeAttachment function', () ->
        expect($scope.commentsCtrl.removeAttachment).to.be.an.instanceof(Function)

      describe 'attachment has id', () ->
        attachment = null

        beforeEach () ->
          attachment = { id: 1 }
          $scope.commentsCtrl.newComment.attachments = [attachment]
          $httpBackend.expectDELETE('/attachments/1.json').respond({ id: 1 })

        it 'expect to remove attachment from comment, after attachment removed', () ->
          $scope.commentsCtrl.removeAttachment(attachment)
          $httpBackend.flush()
          expect($scope.commentsCtrl.newComment.attachments.length).to.equal(0)

        it 'expect to receive success for Notifications, after attachment removed', () ->
          $scope.commentsCtrl.removeAttachment(attachment)
          $httpBackend.flush()
          expect(MockNotifications.success.called).to.be.true

      describe 'attachment without id', () ->
        it 'expect to remove attachment from comment', () ->
          attachment = {}
          $scope.commentsCtrl.newComment.attachments = [attachment]
          $scope.commentsCtrl.removeAttachment(attachment)
          expect($scope.commentsCtrl.newComment.attachments.length).to.equal(0)
