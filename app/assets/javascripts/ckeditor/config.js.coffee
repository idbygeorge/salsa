CKEDITOR.editorConfig = (config) ->
  config.toolbar_TextBlock = [
    ['Bold', 'Italic', '-', 'RemoveFormat'],
    ['Undo', 'Redo'],
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
      elements: 'p strong em ol li ul',
      classes: '*',
      attributes: 'style'
    }
  }

  true