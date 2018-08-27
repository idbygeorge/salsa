
(function($) {
  $(function(){
    var document_workflow_step = $('[data-document-slug]').attr('data-document-slug');
    $("#"+document_workflow_step).show()
  })
})(jQuery);
