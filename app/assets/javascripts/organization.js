(function($) {
  $(function(){
    if ($("body").find( '#organization_track_meta_info_from_document' ).is(":checked") ) {
      $("body").find( '#organization_track_meta_info_from_document' ).parent().parent().next().removeClass("hide");
    } else {
      $("body").find( '#organization_track_meta_info_from_document' ).parent().parent().next().addClass("hide");
    }
    $("body").find( '#organization_track_meta_info_from_document' ).on( "change", function() {
      if ($("body").find( '#organization_track_meta_info_from_document' ).is(":checked") ) {
        $(this).parent().parent().next().removeClass("hide");
      } else {
        $(this).parent().parent().next().addClass("hide");
      }

    });
  });
})(jQuery);
