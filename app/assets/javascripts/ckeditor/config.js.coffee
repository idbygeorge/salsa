CKEDITOR.editorConfig = (config) ->
  config.toolbar_TextBlock = [
    ['Bold', 'Italic', '-', 'RemoveFormat'],
    ['Undo', 'Redo'],
    ['Link', 'Unlink'],
    ['BulletedList', 'NumberedList', '-', 'Outdent', 'Indent'],
    ['JustifyLeft', 'JustifyCenter', 'JustifyRight']
  ]

  # set the default toolbar
  config.toolbar = 'TextBlock'

  # mostly for word
  #config.forcePasteAsPlainText = true

  # offset topbar
  config.floatSpaceDockedOffsetY = 10

  # allow specific elements/classes
  config.allowedContent = {
    '$1': {
      elements: 'p strong em ol li ul',
    },
    ul: {
      classes: '*',
      propertiesOnly: true
    }
  }

  true