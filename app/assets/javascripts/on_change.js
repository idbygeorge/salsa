
(function($) {
  $(function(){
    $("#page").find( ':input:not(:radio):not(:checkbox):not(:text)').on("change", function(){
      $(this).text($(this).val())
    });
    $("#page").find( ':input:text').on("change", function(){
      $(this).attr("value",$(this).val())
    });
    $("#page").find( ':input:checkbox').on("change", function(){
      if($(this).is(':checked')){
        $(this).attr("checked",true)
      } else {
        $(this).removeAttr("checked",true)
      }
    });
    $("#page").find( ':input:radio').on("change", function(){
      $(this).attr("checked",true)
      $(this).siblings("[name="+$(this).attr("name")+"]").removeAttr("checked")
    });
  });
})(jQuery);
