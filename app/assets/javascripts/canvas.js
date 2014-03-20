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

  if(window.location.hash == '#/compilation/clipboard') {
    clipbaordTabIndex = $('#compilation_tabs a[href="#clipboard_tab"]').parent().index();
    $("#tb_save_canvas").trigger('click');
  }

  $("#choose_course_prompt").dialog({
      modal:true,
      maxHeight: editorMaxHeight,
      width: 800,
      autoOpen: chooseCoursePromptAutoOpen,
      closeOnEscape: true,
      title: 'Example | Clipboard | Help',
      position: 'center top+20',
      active: clipbaordTabIndex,
      open: function() {
        $('#clipboard_tab .editableHtml', this).tinymce(tinymceOptions);
        loadingDialog.dialog('close');
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

      $("#tb_save_canvas").data('originaltext', $("#tb_save_canvas").text()).html('Course: <b><em>' + courseData.name.slice(0, 30) + (courseData.name.length > 30 ? '...' : '') + '</em></b>');
      $('#clipboard_tab .editableHtml', coursePrompt).tinymce('destroy');

      if(courseData.syllabus && courseData.syllabus.length) {
        $("#compilation_tabs #clipboard_tab .editableHtml").html(courseData.syllabus);
        $(this).closest('label').after($('<div class="message notice">The syllabus information for <em><b>' + courseData.name + '</em></b> has been imported into the Clipboard.</div>'));
      } else {
        $("#compilation_tabs #clipboard_tab .editableHtml").html('');
        $(this).closest('label').after($('<div class="message warning">No syllabus information for <b><em>' + courseData.name + '</em></b> detected in the LMS.</div>'));
      }

      $('#compilation_tabs ul a[href="#clipboard_tab"]').trigger('click');

      $('#clipboard_tab .editableHtml', coursePrompt).tinymce('create');

      $('#send_canvas').show().removeClass('hidden').append($('<div/>').addClass('details').html('Course: <b><em>' + courseData.name + '</em></b>'));
    } else {
      $("#tb_save_canvas").text($("#tb_save_canvas").data('originaltext'));
      $("#compilation_tabs #clipboard_tab .editableHtml").html('');
    }
  });

  $('#tb_save_canvas, #tb_compilation').on('ajax:success', function(event, xhr, settings) {
    $("#choose_course_prompt").html(xhr.html);

    var loadingDialog;

    $('#tb_send_canvas').on('ajax:beforeSend', function(event, xhr, settings) {
      course_id = $('#course_id').val()
      settings.url = settings.url + "&canvas_course_id=" + course_id
      
      var salsaDocument = $('#page-data').clone();

      // fix headers, canvas doesn't allow h1 tags
      $(':header', salsaDocument).each(function() {
        var number = parseInt(this.tagName.replace(/^h/i, ''), 10);
        $(this).replaceWith($('<h' + (number+1) + '/>').text($(this).text()));
      });

      // remove all hidden content, canvas doesn't like our CSS
      $('.hide, #page_break, .content:has(#grade_scale.inactive), .disabled, #spacer', salsaDocument).remove();

      var pdfLink = $("#pdf_share_link a").clone().text('PDF Version');
      var pdfDiv = $('<div/>').css({ display: 'block', textAlign: 'right', maxWidth: '8in' }).append(pdfLink);

      $('.content:first', salsaDocument).prepend(pdfDiv);

      settings.data = salsaDocument.html();

      $("#choose_course_prompt").dialog("close");

      loadingDialog = $('<div><img alt="Busy" src="/assets/busy.gif"> Sending your SALSA to canvas...</div>').dialog({modal: true, title: "Saving..."});
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

  $('#tb_save_canvas').on('ajax:beforeSend', function(){
    loadingDialog = $('<div><img alt="Busy" src="/assets/busy.gif"> Your course list is being loaded from canvas...</div>').dialog({modal: true, title: "Loading from Canvas"});
    $('.ui-dialog-titlebar-close').html('close | x').removeClass('ui-state-default').focus();
  });

  // TODO: Debugging code... remove when done.
  $('#tb_save_canvas').on('ajax:error', function(event, xhr, settings) {
    console.log("Ajax error saving to canvas...", event, xhr, settings);
  });

});