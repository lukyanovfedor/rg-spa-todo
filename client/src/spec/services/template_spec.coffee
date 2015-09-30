describe 'Template', () ->
  Template = null

  injectorFn = (_Template_) ->
    Template = _Template_

  beforeEach(module('TodoApp'))
  beforeEach(inject(injectorFn))

  describe '.setTitle', () ->
    it 'expect to set title', () ->
      Template.setTitle('yoyo')
      expect(Template.getTitle()).to.equal('yoyo - Todo')

  describe '.getTitle', () ->
    it 'expect to have default title "Todo", when title not set', () ->
      expect(Template.getTitle()).to.equal('Todo')

    it 'expect to return title, with " - Todo", when title set', () ->
      Template.setTitle('Hello')
      expect(Template.getTitle()).to.equal('Hello - Todo')

  describe '.setBodyClasses', () ->
    it 'expect to set body classes', () ->
      Template.setBodyClasses('yoyo')
      expect(Template.getBodyClasses()).to.equal('yoyo')

  describe '.getBodyClasses', () ->
    it 'expect to return body classes', () ->
      expect(Template.getBodyClasses()).to.equal('')
