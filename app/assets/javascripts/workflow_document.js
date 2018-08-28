
(function($) {
  $(function(){
    var document_workflow_step = $('[data-document-slug]').attr('data-document-slug');
    var document_step_type = $('[data-document-step-type]').attr('data-document-step-type');
    if (document_step_type === "end_step") {
      $(".workflow_step").show()
    } else if(document_workflow_step != ""){
      $(".workflow_step:not(#"+document_workflow_step+")").hide()
      $("#"+document_workflow_step).show()
    } else {
      $(".workflow_step").hide()
    }
  })
})(jQuery);
