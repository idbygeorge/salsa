(function($) {
    $(function(){
        $("#preview_control a").on("click", function(){
            $("#preview,#preview_control").hide();
            $(".masthead, #wrapper, footer").show();
            $("#preview_control .previewLabel").remove();
            return false;
        });

        // $("#controlPanel label").mouseup(function(e){
        //     if ($(this).children().is(":not(:checked)")){
        //       $(this).parent().find("[name|='program']")
        //       $(this).parent().siblings().first().before($(this).parent().siblings().last());
        //       $(this).parent().siblings().toggleClass("hide");
        //     }
        // });

        // example
        $("#tb_example").on("click", function(){
            return previewPage('#example','Example');
            $(".editable, .editableHtml", previewPage).removeClass("editable editableHtml").removeAttr("tabindex");
        });

        $("#content_example_link").on("click", function(){
            return previewSection('example','Example');
            $(".editable, .editableHtml", previewSection).removeClass("editable editableHtml").removeAttr("tabindex");
        });

        // help
        $("#tb_help").on("click", function (e){
            e.preventDefault();
            return previewPage("#help_page",'Help');
        });

        $('#tb_resources').on("click", function() {
            $('#help_viewer').removeClass('hidden').dialog({
                modal:true,
                maxHeight: $('body').innerHeight() * .8,
                width: 800,
                closeOnEscape: true,
                title: 'Resources',
                position: 'center ',
                open: function() {
                    $('#compilation_tabs').tabs();

                    $(".ui-dialog-titlebar-close").html("close | x").removeClass("ui-button-icon-only");
                }
            });
        });

        $("#content_help_link").on("click", function(){
            return previewSection('help','Help');
        });

        // disable view
        $("#content_disable_link").on("click", function(){
             var active_page = $('section.active');
             var active_link = $("#tabs .selected a");

             active_page.toggleClass("disabled");
             $("span", this).toggleClass("fi-minus-circle fi-eye");

             syncViewState(active_page, active_link.text());
        });

        // My SALSA
        $("#tb_link").on("click", function (e){
            e.preventDefault();
            var myUrl = document.URL.split('#');
            $("#custom-url").html(myUrl[0]);
            return previewPage("#mySalsa",'Bookmark Your Editable SALSA');
        });

        $("#tb_login_lms").on("click", function(e) {
            $("#choose_institution_prompt").dialog({
                modal: true,
                title: "Login to your institution",
                width: "600px",
                draggable: false,
                create: function() {
                    $(".ui-dialog-titlebar-close").html("close | x").removeClass("ui-button-icon-only");
                }
            });
            e.preventDefault();
        });

        // edit an html block
        $("body").on("click keypress", ".editableHtml,[contenteditable]", function(){
            focusEditor(editor, this);
        }).on("blur", ".editingHtml textarea,[contenteditable]", function(){
            blurEditor(editor, this);
        });


        $("body").on("click", "#topBar a", function(){
          var context = $("#topBar").data('context');
          var parentList = context.source.closest('dl');
          var target = getTarget(context.source);
          var firstItem = target.find('li:first');
          var firstItemText = firstItem.text();

          if(firstItemText == 'Outcome text here' || firstItemText == 'Objective text here.') {
            firstItem.remove();
          }

          var identifier = $(this).data('meta');
          parentList.data({ element: "li", text: $(this).text(), meta: identifier }).find(".ui-state-active").click();

          if(context.unique) {
              //$('[data-meta="'+identifier+'"]', parentList).remove();
              $('[data-meta="'+identifier+'"]', '#topBar').remove();

              if($('#topBar li a').length == 0) {
                  $('#topBar').remove();
                  $("#container").removeAttr("style");

                  $(context.source).removeClass('ui-state-active').addClass('ui-state-disabled');
              }
          }

          return false;
        });


        $("#controlPanel").on("click", "input:not(:radio),#gradeUnitsPercent,#gradeUnitsPoints,dt", function() {
            var result = "";
            var controlParent = $(this).closest("[data-method]");
            var control = controlParent.data();

            control.source = $(this);
            if(!control.original_target) {
                $(control.source).closest("[data-target]").data("original_target", control.target);
            }
            control.target = getTarget(this);
            control.action = $(this).val();

            result = controlMethods[control.method](control);

            initEditor(editor, document);
        });

        //toggler
        $("#controlPanel").on("click", ".toggler", function(){
            $(this).closest("section").toggleClass("ui-state-active ui-state-default");
            $(this).closest("header").next().toggle().find("dt.ui-state-active").removeClass("ui-state-active");

            $("#topBar").remove();
            $("#container").removeAttr("style");

            return false;
        });

        $("a[href='#togglenext']").on("click", function(e){
            $(this).siblings().toggle();

            e.preventDefault();
        });
        // left sidebar section selector

        $("#tabs a").on("click", function(){
            var listItem = $(this).closest("li");
            var list = listItem.closest("ul");

            // section selector
            list.find(".selected").removeClass("selected");
            $(this).closest("li").addClass("selected");

            var section = $(this).attr("href");

            // content
            $("section.active").removeClass("active");
            $(section).removeClass('hide');
            $(section).addClass("active");

            // set the view state messages
            syncViewState(section, $(this).text());

            // control panel
            $("aside.active").removeClass("active").hide();
            $("#controlPanel " + section.replace('#', '.')).addClass("active").show();

            $("body").attr("class", section.replace('#', ''));

            $("#topBar").remove();
            $("#container").removeAttr("style");

            initEditor(editor, document);
        });

        $("a.click_on_init").not('[href^="#"]').on('click', function(){
            window.location = $(this).attr('href');
        });

        //preview
        $('#tb_preview').click(function() {
            if($('.dialog-preview').length) {
                $('#previewWrapper').dialog('close');
            } else {

                var url = $('#tb_save').attr('href');

                if(!url) {
                    url = $('#tb_share').prop('href');
                }

                var content = $('#page-data').html();
                $.ajax({
                    type:'PUT',
                    url:url,
                    data:content,
                    async:false,
                    beforeSend: function(xhr, settings) {
                        xhr.setRequestHeader("Accept", "application/json");
                        var token = $('#tb_save').attr('authenticity_token');
                        xhr.setRequestHeader('X-CSRF-Token',token );
                    }
                });

                var previewHTML = $('<div id="preview-data"/>').append(content);
                var preview = $('#preview').html(previewHTML);

                var previewWrapper = $('#previewWrapper').clone().css({ backgroundColor: "#F5F5F5" });

                $("#preview", previewWrapper).show();
                $("#spacer", previewWrapper).show();
                $('body').addClass('dialog-preview');



                $(".content", previewWrapper).show();
                $(".example", previewWrapper).hide();

                $(".editable, .editableHtml", previewWrapper).removeClass("editable editableHtml").removeAttr("tabindex");
                previewWrapper.html(cleanupDocument(previewWrapper));

                previewWrapper.dialog({
                    modal:true,
                    width:'10.75in',
                    title:'Preview',
                    maxHeight: $(window).innerHeight() - 150,
                    close: function() {
                        $('body').removeClass('dialog-preview');
                        $('#preview').html('').hide();
                        $(this).dialog("destroy");
                    }
                });

                $(".ui-dialog-titlebar-close").html("close | x").removeClass("ui-button-icon-only").focus();
            }

            return false;
        });

        // edit a simple value (no html)
        $("#page").on("click keypress", ".editable", function(){
            var text = $(this).toggleClass("editable editing").text()
            // trim leading and trailing spaces
            text = text.replace(/(^\s+|\s+$)/g, '');

            var editor = $(this).html($("<input/>").attr("id", "headerTextControl").val(text)).find("input");
            if(editor.val() == '0'){
                editor.val('');
            }

            // TODO: make generic validations
            if ($('#grade_components .right').has(editor).length > 0) {
                editor.attr('maxlength',6);
                makeNumericTextbox(editor);
            } else if ($('#extra_credit .right').has(editor).length > 0) {
                editor.attr('maxlength',6);
                makeNumericTextbox(editor);
            } else if ($('#grade_scale').has(editor).length > 0) {
                editor.attr('maxlength',2);
                makeNumericTextbox(editor);
            }

            editor.keydown(function(e){
                var key = e.charCode ? e.charCode : e.keyCode ? e.keyCode : 0;

                if (key == 13){
                    editor.blur();
                }
            });

            editor.focus().select();
        });
    })
})(jQuery);
