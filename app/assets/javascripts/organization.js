(function($) {
  $(function(){

    if ($("body").find( '#organization_track_meta_info_from_document' ).is(":checked") ) {
      $("body").find( '#organization_track_meta_info_from_document' ).parent().parent().next().removeClass("hide");
    } else {
      $("body").find( '#organization_track_meta_info_from_document' ).parent().parent().next().addClass("hide");
    }
    $("body").find( '#organization_track_meta_info_from_document' ).on( "change", function() {
      if ($( this ).is(":checked") ) {
        $(this).parent().parent().next().removeClass("hide");
      } else {
        $(this).parent().parent().next().addClass("hide");
      }
    });
    $("body").find( '#check_ssl' ).on( "change", function() {
      if ($( this ).is(":checked") ) {
        var url = $(this).data("httpsCheckUrl")
        $.ajax({
          type:     "GET",
          url:      url,
          success: function(data){
            $("body").find( '#check_ssl' ).prev().val("true")
          },
          error: function(data){
            alert("HTTPS is not enabled for " + /organizations\/(.*)\//g.exec(window.location.href)[1] );
            $("body").find( '#check_ssl' ).prev().val("false")
            $("body").find( '#check_ssl' ).prop('checked', false);

          }
        });
      } else {
        $("body").find( '#check_ssl' ).prev().val("false")
      }
    });
  });
})(jQuery);
