CKEDITOR.editorConfig = (config) ->
  config.toolbar_TextBlock = [
    ['Undo', 'Redo'],
    ['Bold', 'Italic', '-', 'RemoveFormat'],
    ['Link', 'Unlink'],
    ['BulletedList', 'NumberedList', '-', 'Outdent', 'Indent'],
    
    # these buttons don't work with the config.allowedContent specified...
    # ['JustifyLeft', 'JustifyCenter', 'JustifyRight']
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
      elements: 'p strong em ol li ul div',
      classes: '*',
      attributes: 'style'
    },
    'a': {
      attributes: 'href'
    }
  }

  true