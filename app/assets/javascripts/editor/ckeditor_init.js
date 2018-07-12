CKEditor_configs = {
  block_editor: {
    toolbar: [
      ['Undo', 'Redo'],
      ['Bold', 'Italic', '-', 'RemoveFormat'],
      ['Link', 'Unlink'],
      ['BulletedList', 'NumberedList', '-', 'Outdent', 'Indent'],

      // these buttons don't work with the config.allowedContent specified...
      // ['JustifyLeft', 'JustifyCenter', 'JustifyRight']
    ],

    // mostly for word
    // config.forcePasteAsPlainText = true

    // offset topbar
    floatSpaceDockedOffsetY: 10,

    // allow specific elements/classes
    allowedContent: {
      '$1': {
        elements: 'p strong em ol li ul div',
        classes: '*',
        attributes: 'style'
      },
      'a': {
        attributes: 'href'
      }
    }
  }
}

function CKEditor_focus(context) {

}

function CKEditor_blur(context) {

}

// remove all artifacts of the CKEditor (so the document will play nice with other editors after a save)
function CKEditor_cleanup(context) {
  // remove each editor
  jQuery.each(CKEDITOR.instances, function(){
    if(this.container){
      var editorElement = this.container.$;
      if($(context).has(editorElement).length || $(context).is(editorElement)) {
        this.destroy();
      }
    }
  });

  // remove the side effects of the editor
  $('.editableHtml', context).removeAttr('contenteditable spellcheck role aria-label title aria-describedby style').removeClass('cke_editable cke_editable_inline cke_contents_ltr cke_show_borders');
}

// init the CKEditor - needs to set contenteditable on each element that needs the editor
// or it has annoying side effects (inline editor doesn't go away on first blur, paste gets messed up)
function CKEditor_init(context) {
  // set contenteditable to true for each element that the CKEditor needs to initialize
  jQuery('.editableHtml:visible', context).attr('contenteditable', true).each(function(){
    // make sure there isn't an editor on this element already
    var editor = CKEDITOR.dom.element.get(this).getEditor();

    if(!editor) {
      // init editor for this element
      CKEDITOR.inline(this, CKEditor_configs.block_editor);

      // TODO: add support for header tags being CKEditor fields (limit controls to relevant controls - start with undo/redo only)
      // probably needs to be in the on init handler for this editor...
    }
  });
}
