
//var editor = 'tinyMCE';
var editor = 'CKEditor';

var controlMethods;



function liteOn(x,color){
    $('.control_highlighted').css({ backgroundColor: 'transparent' }).removeClass('control_highlighted');
    $(x).css({ backgroundColor: color }).addClass('control_highlighted');
}
function liteOff(x){
    $(x).css({ backgroundColor: '' }).removeClass('control_highlighted');
}

(function($) {
    $(function(){
        $('#tabs ul').sortable({
            items: 'li:not(:first-child)',
            start: function(e, ui) {
                $("#page section").addClass('active');
                //$("#controlPanel aside").addClass('active').show();
            },
            change: function(e, ui) {
                var tabLink = $('a', ui.item);
                var movedSection = $(tabLink.attr('href'));

                var index = ui.placeholder.index();

                // move all of the sections to the tempElement
                var tempElement = $('<div/>');
                $('#page-data section').appendTo(tempElement);

                // arrange all sections to match list (skip the item being moved for this loop)
                $(this).children(':not(.ui-sortable-helper)').each(function(i){
                    var sectionSelector = $('a', this).attr('href');
                    var section = $(sectionSelector, tempElement);

                    // if we hit the placeholder, it is time to append the section being moved
                    if($(this).is('.ui-sortable-placeholder')) {
                        section = movedSection;
                    }

                    // append the section to move to the page
                    $("#page-data").append(section);
                });
            },
            beforeStop: function(e, ui) {
                var tabLink = $('a', ui.item);
                var section = $(tabLink.attr('href'));

                tabLink.trigger('click');
            }
        });

        $('#messages div').delay(5000).fadeOut(1000, function() {
            $(this).remove();
        });

        $(".click_on_init").trigger('click');
        // loop through all sections and sync up the control panel to the document's current state
        $.each(sectionsNames, function (i){
            // store the current section's name
            var sectionName = this;

            // find the element for this section
            var currentsection = $("#" + sectionName);

            // loop through all sub sections in the current section
            currentsection.find('[class^=section]').each(function() {
                // get the subSection's class name
                var subSectionClassName = $(this).attr('class').replace(/(.+\s)?(section[^\s]+)(.+|$)/, '$2');

                // find the control for this section
                var sectionToggleControl = $("aside." + sectionName).find("[data-target='." + subSectionClassName + "']");

                // sync the controls state for this section with the document
                if($(this).hasClass("hide")){
                    sectionToggleControl.removeClass("ui-state-active").addClass("ui-state-default");
                } else {
                    sectionToggleControl.removeClass("ui-state-default").addClass("ui-state-active");
                }
            });
        });


        // make stuff editable
        $(".editableHtml,.editable", "section").attr({ tabIndex: 0 });
        $("section article .text,#templates .text").addClass("editableHtml");


        $("section").on("blur", ".editing input", function(){
            var element = $(this).closest(".editing");
            var text = $(this).val();

            if(text == '' && $(this).parent().hasClass('right') == true){
                text = '-';
            }

            var promptText = 'Please enter a title or disable this section';

            if(element.is('h2') && text == '') {
                text = promptText;
                element.addClass('prompt');
            } else if(element.hasClass('prompt') && text != promptText) {
                element.removeClass('prompt');
            }

            if (text == "" && element.data('can-delete') == true) {
                element.remove();
            } else {
                // blur triggers twice when the window loses focus so we need to explicitly add and remove the needed classes
                element.html(text).removeClass("editing");
                element.html(text).addClass("editable");

                if ($('#grades').has(element)) {
                    updateGradesPage(element);
                }
            }
        });

        $('#tb_save, #tb_share').on('ajax:beforeSend', function(event, xhr, settings) {
            if($('body').hasClass('disable-save')) {
                xhr.abort();
                return false;
            }
            meta_data_from_doc = []
            $("#page").find( '[data-meta]' ).each(function() {
              meta_data_from_doc.push("salsa_" + $( this ).attr( 'data-meta' ));
              meta_data_from_doc.push($( this ).text().replace(/\s+/mg, ' '));
            });

            settings.data = cleanupDocument($('#page-data').html());

            var document_version = $('[data-document-version]').attr('data-document-version');

            var queryStringStart = settings.url.search(/\?/) < 0 ? '?' : '&';
            settings.url = settings.url + queryStringStart + 'document_version=' + document_version;
            settings.url = settings.url + '&meta_data_from_doc=' + '[' + meta_data_from_doc + ']';
            settings.url = encodeURI(settings.url);

            notification('Saving...');
        });

        $('#tb_save').on('ajax:success', function(event, data, xhr, settings) {
            if(data.status == 'ok') {
              $("#save_prompt").html('saved at: ' + new Date().toLocaleTimeString()).delay(5000).fadeOut(1000);
              $('[data-document-version]').attr('data-document-version', data.version);
            } else {
              $("#save_prompt").css({display: 'block', zIndex: 999999999, top: 30, position: 'fixed', width: '100%', textAlign: 'center', backgroundColor: '#f99', borderBottom: 'solid 1px #ddd'}).html(data.message).delay(5000).fadeOut(1000);
            }

        });

        $('#extra_credit').on('blur', '.editing :input', function() {
            callbacks['updateTableSum']({ target: '#extra_credit' });
        });

        // publish
        $("#share_prompt").dialog({ modal:true, width:600, title:'Publish', autoOpen:false });
        $(".ui-dialog-titlebar-close").html("close | x").removeClass("ui-button-icon-only").focus();

        $('#tb_share').on('ajax:beforeSend', function(event, xhr, settings) {
            if($('body').hasClass('disable-save')) {
                xhr.abort();
                return false;
            }

            settings.data = cleanupDocument($('#page-data').html());

            var document_version = $('[data-document-version]').attr('data-document-version');
            settings.url = settings.url + '&document_version=' + document_version;


            $('#save_message').show();
            $('#pdf_share_link').hide();
        });

        $('#tb_share').on('ajax:success', function(event,data) {
          if(data.status == 'ok') {
            $('[data-document-version]').attr('data-document-version', data.version);
            $('#share_prompt').dialog('open');

              // should be save to LMS...
            if($('#skip-lms').html() != 'true') {
              $('#tb_send_canvas').trigger('click');
            }

            setTimeout(
              function() {
                $('#save_message').hide();
                $('#pdf_share_link').removeClass('hidden').show();
              }, 15000
            );
          } else {
            notification(data.message);
          }
        });

        // select course from LMS
        $("#course_prompt").dialog({ modal:true, width:500, title:'Select Course', autoOpen:false });
        $(".ui-dialog-titlebar-close").html("close | x").removeClass("ui-button-icon-only").focus();

        // table drag and drop
        $("#grade_components,#extra_credit,table.sortable").tableDnD({ onDragClass: "myDragClass",});

        // load the information section by default
        $("#controlPanel aside").hide();
        if ($("#edit_syllabus")) {
            $("#tabs a").first().click();
        }

        $("body").append($("<label>Edit Section Heading</label>").addClass("visuallyhidden")); // huh?

        $('#tb_save_canvas').on('ajax:beforeSend', function(){
            $('#loading_courses_dialog').removeClass('hidden').dialog({modal: true, width: 500, title: "Loading from Canvas"});
            $('.ui-dialog-titlebar-close').html('close | x').removeClass('ui-button-icon-only').focus();
        });

        $(window).on('hashchange', function() {
            $('.ui-dialog-content').dialog('close');

            if(window.location.hash === '#/resources' || window.location.hash === '#CanvasImport_tab') {
                $("#tb_resources").trigger('click');
                $('#compilation_tabs a[href="#CanvasImport_tab"]').trigger('click');
            } else if(window.location.hash == '#/select/course') {
                $("#tb_save_canvas").trigger('click');
            } else if (window.location.hash.search(/^#[a-z]+$/) === 0) {
                $('#tabs a[href="' + window.location.hash + '"]').trigger('click');
            }
        }).trigger('hashchange');

        initEditor(editor, $('#page'));

        $('#republish').on("shown.bs.modal", function(e){
          console.log('here');
        })
    });
})(jQuery);
