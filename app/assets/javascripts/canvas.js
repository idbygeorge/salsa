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

  var clipbaordTabIndex = 0;
  var chooseCoursePromptAutoOpen = false;
  var loadingDialog;

  $("#choose_course_prompt").dialog({
      modal:true,
      maxHeight: editorMaxHeight,
      width: 500,
      autoOpen: chooseCoursePromptAutoOpen,
      closeOnEscape: true,
      title: 'Select Course',
      position: 'center ',
      open: function() {
        $('#loading_courses_dialog').dialog('close');
      },
      close: function() {
        window.location.hash = '';
      }
  });

  $('.ui-dialog-titlebar-close').html('close | x').removeClass('ui-state-default').focus();

  $('#choose_course_prompt').on('change', '#course_id',  function(){
    var coursePrompt = $(this).closest("#choose_course_prompt");
    coursePrompt.find('.message').remove();

    // remove course title from publish prompt
    $('#send_canvas').hide().find('.details').remove();

    if($(this).val()) {
      var courseData = { id: $(this).val(), name: courses[this.selectedIndex-1].name, syllabus: courses[this.selectedIndex-1].syllabus_body };

      $('body').attr('data-course', JSON.stringify(courseData));

      $("#tb_save_canvas").data('originaltext', $("#tb_save_canvas").text()).html('<span style="color: black;">' + 'Connected to: <b><em>' + courseData.name.slice(0, 15) + (courseData.name.length > 15 ? '...' : '') + '</em></b></span>');
      $('#CanvasImport_tab .editableHtml', coursePrompt).tinymce('destroy');

      if(courseData.syllabus && courseData.syllabus.length) {
        // store syllabus content in the clipboard
        $("#compilation_tabs #CanvasImport_tab .editableHtml").html(courseData.syllabus);
        
        // generate message
        var newMessage = $('<div class="courseSyllabusRetrieved"/>').html('The HTML from the <em><b>' + courseData.name + '</em></b> syllabus editor has been imported into the <a href="#CanvasImport_tab"><em>Canvas Import</em></a> tab in <b>Resources</b>.');

        // put message in message queue
        $("#messages").prepend(newMessage);

        newMessage.delay(8000).fadeOut(1000, function(){
          $(this).remove();
        });
      } else {
        $("#compilation_tabs #CanvasImport_tab .editableHtml").html('');
        $(this).closest('label').after($('<div class="message warning">No syllabus information for <b><em>' + courseData.name + '</em></b> detected in the LMS.</div>'));
      }

      // update the course selection link to show the currently selected course's title
      $('#send_canvas').show().removeClass('hidden').append($('<div/>').data('course', courseData).addClass('details').html('<b><em>' + courseData.name.slice(0, 30) + (courseData.name.length > 30 ? '...' : '') + '</em></b>'));

      // close the dialog
      $('#choose_course_prompt').dialog('close');
    } else {
      $("#tb_save_canvas").text($("#tb_save_canvas").data('originaltext'));
      $("#compilation_tabs #CanvasImport_tab .editableHtml").html('');
    }
  });

  $('#tb_save_canvas').on('ajax:success', function(event, xhr, settings) {
    $("#choose_course_prompt").html(xhr.html);

    var loadingDialog;

    $('#tb_send_canvas').on('ajax:beforeSend', function(event, xhr, settings) {
      course_id = $('#course_id').val()
      settings.url = settings.url + "&canvas_course_id=" + course_id
      
      var salsaDocument = $('#page-data').clone();

      // fix styling on div elements inside of headers (title looks terrible in canvas otherwise)
      $(':header div', salsaDocument).each(function() {
        $(this).css({ lineHeight: 1.4 });
      });

      // fix headers, canvas doesn't allow h1 tags
      $(':header', salsaDocument).each(function() {
        var number = parseInt(this.tagName.replace(/^h/i, ''), 10);
        $(this).replaceWith($('<h' + (number+1) + '/>').html($(this).html()));
      });

      // remove all hidden content, canvas doesn't like our CSS
      $('.hide, #page_break, .page-break, .content:has(#grade_scale.inactive), .disabled, #spacer, [style*="display: none;"]', salsaDocument).remove();

      var htmlLink = $("#html_share_link a").clone().text('SALSA HTML');
      var htmlDiv = $('<div/>').css({ display: 'block', textAlign: 'right', maxWidth: '8in' }).append(htmlLink);

/*      var pdfLink = $("#pdf_share_link a").clone().text('PDF Version');
      var pdfDiv = $('<div/>').css({ display: 'block', textAlign: 'right', maxWidth: '8in' }).append(pdfLink);*/

      $('.content:first', salsaDocument).prepend(htmlDiv);

      settings.data = salsaDocument.html();

      $("#choose_course_prompt").dialog("close");

      loadingDialog = $('<div>Sending your SALSA to canvas...</div>').prepend($('#save_prompt img').clone()).dialog({modal: true, title: "Saving..."});
      $('.ui-dialog-titlebar-close').html('close | x').removeClass('ui-state-default').focus();
    });

    $('#tb_send_canvas').on('ajax:error', function(event, xhr, settings) {
      $('<div>There was an error saving your SALSA to Canvas.</div>').dialog({modal: true, title: 'Error'});
      $('.ui-dialog-titlebar-close').html('close | x').removeClass('ui-state-default').focus();
    }).on('ajax:success', function(event, xhr, settings) {
      $('<div>Your SALSA was successfully saved to canvas.</div>').dialog({modal: true, title: 'Success'});
      $('.ui-dialog-titlebar-close').html('close | x').removeClass('ui-state-default').focus();
    }).on('ajax:complete', function(event, xhr, settings) {
      loadingDialog.dialog('close');
    });

    $("#choose_course_prompt").dialog("open");
  });

  // TODO: Debugging code... remove when done.
  $('#tb_save_canvas').on('ajax:error', function(event, xhr, settings) {
    console.log("Ajax error saving to canvas...", event, xhr, settings);
  });
});