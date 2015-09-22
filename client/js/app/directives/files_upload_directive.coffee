FilesUploadDirective = () ->
  ctrl = ($scope) ->
    $scope.files = $scope.files || []


  link = (scope, el) ->
    drop = angular.element(el[0].querySelector('.drop-area'))
    input = angular.element(el[0].querySelector('input'))

    drop.on('dragover', (ev) =>
      ev.preventDefault()
      ev.stopPropagation()

      el.addClass('dragover')
    )

    drop.on('dragleave', (ev) =>
      ev.preventDefault()
      ev.stopPropagation()

      el.removeClass('dragover')
    )

    drop.on('drop', (ev) =>
      ev.preventDefault()
      ev.stopPropagation()

      el.removeClass('dragover')

      dataTransfer = if ev.dataTransfer then ev.dataTransfer else ev.originalEvent.dataTransfer
      files = dataTransfer.files

      scope.files.push(file) for file in files

      scope.$apply()
    )

  return {
    restrict: 'A'
    replace: true
    scope:
      files: '=filesUpload'
    template: [
      '<div class="files-upload">',
        '<div class="drop-area"></div>',
        '<input type="file" multiple />',
      '</div>'
    ].join('')
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
