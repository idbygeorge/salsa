$(function() {

  $("#choose_course_prompt").dialog({
      modal:true,
      height:400,
      width: 800,
      autoOpen:false,
      closeOnEscape: true
  });

  $('#tb_save_canvas').on('ajax:success', function(event, xhr, settings) {
    $("#choose_course_prompt").html(xhr.html);

    $('#tb_send_canvas').on('ajax:beforeSend', function(event, xhr, settings) {
      course_id = $('#course_id').val()
      settings.url = settings.url + "&canvas_course_id=" + course_id
      settings.data = $('#page-data').html();
      $("#choose_course_prompt").dialog("close");
    });

    $('#tb_send_canvas').on('ajax:error', function(event, xhr, settings) {
      console.log("Saving syllabus to canvas error");
    });

    $("#choose_course_prompt").dialog("open");
  });

  $('#tb_save_canvas').on('ajax:error', function(event, xhr, settings) {
    console.log("Ajax error");
  });

});


