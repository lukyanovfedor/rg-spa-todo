'use strict'

FilesUploadDirective = () ->
  ctrl = ($scope) ->
    $scope.addFiles = (files) ->
      $scope.files.push(file) for file in files

  link = (scope, el) ->
    drop = el.find('div')
    input = el.find('input')

    drop.on('dragover', (ev) ->
      ev.preventDefault()
      ev.stopPropagation()
      el.addClass('dragover')
    )

    drop.on('dragleave', (ev) ->
      ev.preventDefault()
      ev.stopPropagation()
      el.removeClass('dragover')
    )

    drop.on('drop', (ev, hh) ->
      ev.preventDefault()
      ev.stopPropagation()
      el.removeClass('dragover')

      dataTransfer = if ev.dataTransfer then ev.dataTransfer else ev.originalEvent.dataTransfer
      files = dataTransfer.files

      scope.$apply () ->
        scope.addFiles(files)
    )

    drop.on('click', (ev) ->
      input[0].click()
    )

    input.on('change', (ev) ->
      ev.preventDefault()
      ev.stopPropagation()

      files = ev.target.files

      scope.$apply () ->
        scope.addFiles(files)
    )

  return {
    restrict: 'A'
    replace: true
    scope:
      files: '=filesUpload'
    templateUrl: 'templates/directives/files_upload.html'
    controller: [
      '$scope',
      ctrl
    ]
    link: link
  }

angular
  .module('TodoApp')
  .directive('filesUpload', [
    FilesUploadDirective
  ])
