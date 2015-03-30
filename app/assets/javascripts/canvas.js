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

  var syncPublishButton = function(courseData) {
    if(courseData && courseData.id) {
      $('#send_canvas').show().removeClass('hidden').append($('<div/>').data('course', courseData).addClass('details').html('<b><em>' + courseData.name.slice(0, 30) + (courseData.name.length > 30 ? '...' : '') + '</em></b>'));
    } else {
      $('#send_canvas').hide().addClass('hidden').find('.details').remove();
    }
  };

  syncPublishButton($('#editor_view').data('lmsCourse'));

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

    var courseID = $(this).val();

    if(courseID) {
      var courseData = courses[courseID];

      $('#editor_view').data('lmsCourse', courseData);

      $("#tb_save_canvas").data('originaltext', $("#tb_save_canvas").text()).html('<img src="https://lms.instructure.com/favicon.ico" height="16" alt="Canvas"> &nbsp;' + courseData.name.slice(0, 15) + (courseData.name.length > 15 ? '...' : '')).removeClass('highlight');

      if(courseData.syllabus_body && courseData.syllabus_body.length) {
        // store syllabus_body content in the clipboard

        // don't do this. IDs are duplicated, messed up js for control panel if there are any duplicate IDs for controlled elements
        //$("#compilation_tabs #CanvasImport_tab .editableHtml").html(courseData.syllabus_body);
        $("#compilation_tabs #CanvasImport_tab .editableHtml").html('');

        // generate message
        var newMessage = $('<div class="courseSyllabusRetrieved"/>').html('This SALSA is now connected to <em><b>' + courseData.name + '</em></b>');

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
      syncPublishButton(courseData);

      // close the dialog
      $('#choose_course_prompt').dialog('close');
    } else {
      $("#tb_save_canvas").text($("#tb_save_canvas").data('originaltext'));
      $("#compilation_tabs #CanvasImport_tab .editableHtml").html('');
    }
  });

  $('#choose_course_prompt').on('change', '#replace_course_id',  function(){
    var coursePrompt = $(this).closest("#choose_course_prompt");
    coursePrompt.find('.message').remove();

    if($(this).val()) {
      var courseData = courses[$(this).val()];

      $('#editor_view').data('lmsCourse', courseData);

      $("#tb_save_canvas").data('originaltext', $("#tb_save_canvas").text()).html('<img src="https://lms.instructure.com/favicon.ico" height="16" alt="Canvas"> &nbsp;' + courseData.name.slice(0, 15) + (courseData.name.length > 15 ? '...' : '')).removeClass('highlight');

      if(courseData.syllabus_body && courseData.syllabus_body.length) {
        // store syllabus_body content in the clipboard

        // don't do this. IDs are duplicated, messed up js for control panel if there are any duplicate IDs for controlled elements
        //$("#compilation_tabs #CanvasImport_tab .editableHtml").html(courseData.syllabus_body);
        $("#compilation_tabs #CanvasImport_tab .editableHtml").html('');

        // generate message
        var newMessage = $('<div class="courseSyllabusRetrieved"/>').html('This SALSA is now connected to <em><b>' + courseData.name + '</em></b>');

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
      syncPublishButton(courseData);

      // close the dialog
      //$('#choose_course_prompt').dialog('close');
      var replaceLink = $('#replace_course_email_link', '#choose_course_prompt');

      replaceLink.attr('href', replaceLink.attr('href') + $(this).val() + ' (' + courses[$(this).val()]['name'] + ')');
    } else {
      $("#tb_save_canvas").text($("#tb_save_canvas").data('originaltext'));
      $("#compilation_tabs #CanvasImport_tab .editableHtml").html('');
    }
  });

  $('#tb_save_canvas').on('ajax:success', function(event, xhr, settings) {
    $("#choose_course_prompt").html(xhr.html);

    $("#choose_course_prompt").dialog("open");
  });

  var loadingDialog;

  $('#tb_send_canvas').on('ajax:beforeSend', function(event, xhr, settings) {
    $(this).html('Publishing...').prepend($('<span class="in-progress"></span>'));

    course_id = $('#editor_view').data('lmsCourse').id;
    settings.url = settings.url + "&canvas_course_id=" + course_id;

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
    $('.hide, #page_break, .page-break, .content:has(#grade_scale.inactive), .disabled, #spacer, [style*="display: none;"], .dynamic-component, script', salsaDocument).remove();

    if (typeof(html_share_link_text) == 'undefined'){
      html_share_link_text = 'SALSA HTML';
    }

    var htmlLink = $("#html_share_link a").clone().text(html_share_link_text).attr({ 'id': 'salsa_document_view_link' });

    var htmlDiv = $('<div/>').css({ float: 'right' }).append(htmlLink);

/*      var pdfLink = $("#pdf_share_link a").clone().text('PDF Version');
    var pdfDiv = $('<div/>').css({ display: 'block', textAlign: 'right', maxWidth: '8in' }).append(pdfLink);*/

    $('.content:first', salsaDocument).prepend(htmlDiv);

    settings.data = salsaDocument.html();

    $("#choose_course_prompt").dialog("close");
  });

  $('#tb_send_canvas').on('ajax:error', function(event, xhr, settings) {
    $('#send_canvas .details').html('There was a problem publishing to Canvas');
  }).on('ajax:success', function(event, xhr, settings) {
    $('#send_canvas .details').html(new Date());
  }).on('ajax:complete', function(event, xhr, settings) {
    $('.in-progress', this).remove();
    $(this).html('Sent to Canvas');
  });
});
