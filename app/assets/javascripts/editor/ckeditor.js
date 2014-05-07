// dynamic editableHTML fields need to be preped and initialzed
function CKEditor_focus(context) {
  var editor = CKEDITOR.dom.element.get(context).getEditor();

  jQuery(context).attr('contenteditable', true);

  if(!editor) {
    CKEDITOR.inline(context);

    editor = CKEDITOR.dom.element.get(context).getEditor();

    // TODO: add support for header tags being CKEditor fields (limit controls to relevant controls - start with undo/redo only)
  }
}

function CKEditor_blur(context) {
  // TODO: dynamic fields still have a blur issue...  if you resolve this, you probably
  // don't need the hack at the bottom of this file anymore
}

// remove all artifacts of the CKEditor (so the document will play nice with other editors)
function CKEditor_cleanup(context) {
  // remove each editor
  jQuery.each(CKEDITOR.instances, function(){
    this.destroy();
  });

  // remove the side effects of the hack
  $('#page .editableHtml').removeAttr('contenteditable');
}

// HACK: inline ckeditor seems to play much nicer with content that already has the
// contenteditable attribute set on it
// (inline editor doesn't go away on first blur if you add each one manually)
function CKEditor_init(context) {
  // only apply fix if using the CKEditor
  if(editor === 'CKEditor') {
    // set contenteditable to true for each element that the CKEditor needs to initialize
    jQuery('#page .editableHtml').attr('contenteditable', true);
  }
}