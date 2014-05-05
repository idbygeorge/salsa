function CKEditor_init(context) {
  // ckeditor seems to require the contenteditable attribute
  // to be set for the inline editor to actually work
  $(context).attr('contenteditable', true);

  var editor = CKEDITOR.dom.element.get(context).getEditor();

  if(!editor) {
    CKEDITOR.inline(context);

    editor = CKEDITOR.dom.element.get(context).getEditor();
    // blur is messed up on first time... not sure why.
  }
}

function CKEditor_destroy(context) {
  console.log(context);

  var editor = CKEDITOR.dom.element.get(context).getEditor();

  if (editor){
      editor.destroy();
  }
}