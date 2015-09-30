describe 'Comments', () ->
  Comments = null
  CommentResource = null
  $httpBackend = null

  injectorFn = (_Comments_, _$httpBackend_, _CommentResource_) ->
    Comments = _Comments_
    $httpBackend = _$httpBackend_
    CommentResource = _CommentResource_

  beforeEach(module('TodoApp'))
  beforeEach(inject(injectorFn))

  describe '.getComments', () ->
    it 'expect to return comments', () ->
      expect(Comments.getComments().length).to.equal(0)

  describe '.setComments', () ->
    it 'expect to set comments', () ->
      Comments.setComments(['comment', 'another one'])
      expect(Comments.getComments().length).to.equal(2)

  describe '.create', () ->
    it 'expect to add comment to service comments, after creation', () ->
      prms =
        task_id: 1,
        note: 'hello'

      $httpBackend.expectPOST('/tasks/1/comments.json').respond(200, JSON.stringify(prms))
      comment = new CommentResource(prms)
      Comments.create(comment)
      $httpBackend.flush()
      expect(Comments.getComments().length).to.equal(1)

  describe '.destroy', () ->
    it 'expect to remove comment from service comments, after deleting', () ->
      prms =
        task_id: 1,
        note: 'hello'

      $httpBackend.expectPOST('/tasks/1/comments.json').respond(200, JSON.stringify(prms))
      $httpBackend.expectDELETE('/comments/1.json').respond(200, JSON.stringify(prms))

      comment = new CommentResource(prms)
      Comments.create(comment)
      comment.id = 1
      Comments.destroy(comment)
      $httpBackend.flush()
      expect(Comments.getComments().length).to.equal(0)
