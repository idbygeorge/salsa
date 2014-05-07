function CKEditor_focus(context) {
  
}

function CKEditor_blur(context) {

}

// remove all artifacts of the CKEditor (so the document will play nice with other editors after a save)
function CKEditor_cleanup(context) {
  // remove each editor
  // TODO: needs to be scoped to context
  jQuery.each(CKEDITOR.instances, function(){
    this.destroy();
  });

  // remove the side effects of the editor
  $('.editableHtml', context).removeAttr('contenteditable');
}

// init the CKEditor - needs to set contenteditable on each element that needs the editor
// or it has annoying side effects (inline editor doesn't go away on first blur, paste gets messed up)
function CKEditor_init(context) {
  // HACK: editors aren't active on other tabs... probably something with CKEditor that doesn't init them if the are hidden
  $activeTab = jQuery("#page section.active");
  jQuery("#page section").addClass('active');

  // set contenteditable to true for each element that the CKEditor needs to initialize
  jQuery('.editableHtml', context).attr('contenteditable', true).each(function(){
    // make sure there isn't an editor on this element already
    var editor = CKEDITOR.dom.element.get(this).getEditor();

    if(!editor) {
      // init editor for this element
      CKEDITOR.inline(this);

      // TODO: add support for header tags being CKEditor fields (limit controls to relevant controls - start with undo/redo only)
      // probably needs to be in the on init handler for this editor...
    }
  });

  // complete the hack
  setTimeout(function() {
    jQuery('#page section').not($activeTab).removeClass('active');
  }, 100);
}