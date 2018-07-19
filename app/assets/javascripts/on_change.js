
(function($) {
  $(function(){
    $("#page").find( ':input:not(:radio):not(:checkbox):not(:text)').on("change", function(){
      $(this).text($(this).val())
    });
    $("#page").find( ':input:text').on("change", function(){
      $(this).attr("value",$(this).val())
    });
    $("#page").find( ':input:radio,:checkbox').on("change", function(){
      $(this).is(':checked')
    });
  });
})(jQuery);
