$(function() {
  var editorMaxHeight = $('body').innerHeight() * .6;

  var tinymceOptions = {
    toolbar: "bold italic underline | undo redo | bullist numlist | link unlink",
    statusbar: false,
    menubar : false,

    plugins : "autoresize,link,autolink,paste",
    
    autoresize_max_height: editorMaxHeight,

    content_css : "/stylesheets/content.css",
    width: '300',
    height: '400',
    auto_focus: 'contentTextControl',
    setup : function(ed) {
        ed.on('focus', function(e){
            var maxHeight = $("body", this.contentDocument).height();

            this.theme.resizeTo(
                '100%',
                Math.min(editorMaxHeight, maxHeight)
            );
        });
    }
  };

  $("#choose_course_prompt").dialog({
      modal:true,
      maxHeight: '80%',
      width: 800,
      autoOpen:false,
      closeOnEscape: true,
      title: 'Helper',
      position: 'center top+20',
      open: function() {
        $('#clipboard_tab .editableHtml', this).tinymce(tinymceOptions);
      }
  });

  $('.ui-dialog-titlebar-close').html('close | x').removeClass('ui-state-default').focus();

  $('#choose_course_prompt').on('change', '#course_id',  function(){
    var coursePrompt = $(this).closest("#choose_course_prompt");
    var courseData = { id: $(this).val(), name: courses[this.selectedIndex-1].name, syllabus: courses[this.selectedIndex-1].syllabus_body };

    $('body').attr('data-course', JSON.stringify(courseData));

    $("#tb_save_canvas").text('Course: ' + courseData.name.slice(0, 30) + (courseData.name.length > 30 ? '...' : ''));

    coursePrompt.find('.message').remove();
    $('#clipboard_tab .editableHtml', coursePrompt).tinymce('destroy');

    if(courseData.syllabus && courseData.syllabus.length) {
      $("#compilation_tabs #clipboard_tab .editableHtml").html(courseData.syllabus);
      $(this).closest('label').after($('<div class="message notice">The syllabus for the <em>' + courseData.name + '</em> course has been loaded into the clipboard for easy access.</div>'));
    } else {
      $("#compilation_tabs #clipboard_tab .editableHtml").html('');
      $(this).closest('label').after($('<div class="message warning">There does not appear to be an existing syllabus for the <em>' + courseData.name + '</em> course.</div>'));
    }

    $('#compilation_tabs ul a[href="#clipboard_tab"]').trigger('click');

    $('#clipboard_tab .editableHtml', coursePrompt).tinymce('create');
  });

  $('#tb_save_canvas, #tb_compilation').on('ajax:success', function(event, xhr, settings) {
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


