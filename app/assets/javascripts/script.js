/* Author: John Pope
 * Utah State University - 2012
*/

function liteOn(x,color){
    x.style.backgroundColor=color;
}
function liteOff(x){
    x.style.backgroundColor="#fff";
}
(function($) {
    $(function(){
        $('#messages div').delay(5000).fadeOut(1000, function() {
            $(this).remove();
        });

        $("a[href=#togglenext]").on("click", function(){
            $(this).siblings().toggle();

        });

        $(".click_on_init").trigger('click');

        // Check for existing sections and toggle their tab
        var tabs = ["information", "outcomes", "resources", "activities", "policies", "grades"]
        $.each(tabs, function (i){
            var j=2;
            for(var j=2; j<5; j++){
                if(!$("#"+tabs[i]).find(".section"+j).hasClass("hide")){
                    $("aside."+tabs[i]).find("[data-target='.section"+j+"']").removeClass("ui-state-default").addClass("ui-state-active");
                }
            }
        });
        // for some reason page break is opposite
        if($("#section5P").hasClass("hide")){
            $("aside.policies").find("[data-target='.section5']").removeClass("ui-state-active").addClass("ui-state-default");
        }

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
        });

        // control panel
        var getTarget = function(source) {
            var target = $(source).closest("[data-target]").data("target");

            // if the target is a string, it is a selector, if it is an object, it is already set to the right element(s)
            if(typeof(target) !== "string" && target.length) {
                if(!target.closest("body").length) {
                    target = $(source).closest("[data-target]").data("original_target");
                } else {
                    return $(target);
                }
            }

            var targetSelector = "";
            $(source).parents("[data-target]").each(function(){
                var selector = $(this).attr("data-target");
                targetSelector = selector + " " + targetSelector;
            });

            return $(targetSelector);
        };

        $("#controlPanel").on("click", ".toggler", function(){
            $(this).closest("section").toggleClass("ui-state-active ui-state-default");
            $(this).closest("header").next().toggle().find("dt.ui-state-active").removeClass("ui-state-active");

            $("#topBar").remove();
            $("#container").removeAttr("style");

            return false;
        });

        $("body").on("click", "#topBar a", function(){
            if($("#controlPanel .active dl").data('target').find('li:first').text() == 'Outcome text here') {
                $("#controlPanel .active dl").data('target').find('li:first').remove();
            }

            $("#controlPanel .active dl").data({ element: "li", text: $(this).text() }).find(".ui-state-active").click();

            return false;
        });

        $("#controlPanel").on("click", "input,dt", function() {
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

            return false;
        });

        // grades
        var updateGradesPage = function(element){
            var args = {
                target: $('#grade_components')
            };

            var grade_scale = $('#grade_scale');

            if(grade_scale.has(element).length) {
                callbacks['validateGradeScale']({ target: grade_scale });
            }

            callbacks.updateGradeScale(args);

            return;
        };

        // make stuff editable
        $("section .editableHtml").attr({ tabIndex: 0 });
        $("section article .text,#templates .text").addClass("editableHtml");

        // edit an html block
        $("body").on("click keypress", "section .editableHtml", function(){
            var element = $(this);
            var text = element.toggleClass("editableHtml editingHtml").html();

            element.html($("<textarea/>").attr("id", "contentTextControl").val(text)).find("textarea");
            element.append($("<div id='old_html'>" + text + '</div>'));

            var editorMaxHeight = $('body').innerHeight() * .8;

            $('#contentTextControl', this).tinymce({
                toolbar: "bold italic underline | undo redo | bullist numlist indent outdent | link unlink",
                statusbar: false,
                menubar : false,

                plugins : "autoresize,link,autolink,paste",
                
                autoresize_max_height: editorMaxHeight,
                paste_as_text: true,
                //paste_word_valid_elements: "b,strong,i,em,h1,h2,h3,h4",

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

                    ed.on('blur', function(e){
                        ed.remove();
                        $(".editingHtml textarea").blur();
                    });
                }
            });
        });

        $("section").on("blur", ".editingHtml textarea", function(){
            var html = $(this).val();
            if (html.length == 0)
                html = $('#old_html').html();
            var element = $(this).closest(".editingHtml");
            element.html(html);
            element.toggleClass("editableHtml editingHtml");
        });

        var makeNumericTextbox = function(editor){
            editor.on('keyup focus change', function(e){
                if ($.inArray(e.which, [37, 38, 39, 40]) != -1) return false;
                editor.val(editor.val().replace(/\D/g, ''));
            });

            editor.on('blur', function(e){
                if (!parseInt(editor.val())) {
                    editor.val('-');
                }
            });
        };

        // edit a simple value (no html)
        $("#page").on("click keypress", ".editable", function(){
            var text = $(this).toggleClass("editable editing").text();

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

        $("section").on("blur", ".editing input", function(){
            if($(this).val() == '' && $(this).parent().hasClass('right') == true){
                $(this).val('-');
            }

            var text = $(this).val();
            var element = $(this).closest(".editing");

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

        // preview control
        var previewSection = function(content_type, preview_label){
            var active_page = $('section.active').attr('id');
            return previewPage("#" + content_type + "_" + active_page, preview_label);
        };

        var previewPage = function(selector, preview_label){
            $(selector).dialog({
                width: 900,
                modal: true,
                title: preview_label,
                maxHeight: $(window).innerHeight() - 150,
                close: function() {
                    $(this).dialog("destroy");
                }
            });
            $(".ui-dialog-titlebar-close").html("close | x").removeClass("ui-state-default").focus();
        };

        var syncViewState = function(viewSelector, viewName) {
            // remove the message to re-enable this view
            $(".enableViewMessage").remove();

            // make sure the view disable link's icon matches the state of the section
            if($(viewSelector).hasClass("disabled")) {
                $("#content_disable_link span").removeClass("fi-minus-circle").addClass("fi-eye");

                // add the message to re-enable this view
                enableViewMessage(viewName);
            } else {
                $("#content_disable_link span").removeClass("fi-eye").addClass("fi-minus-circle");
            }
        }

        var enableViewMessage = function(view_name) {
            var messageElement = $("<div class='message'></div>").text("The " + view_name + " view has been disabled.");
            var enableButton = $("<button class='enable_view'></button>").text("Enable the " + view_name + " view").on("click", function(){
                $("#content_disable_link").trigger('click');
            });
            var viewMessageElement = $("<div class='enableViewMessage'></div>").append(messageElement).append(enableButton);

            $("#container").append(viewMessageElement);
        }

        $("#preview_control a").on("click", function(){
            $("#preview,#preview_control").hide();
            $(".masthead, #wrapper, footer").show();
            $("#preview_control .previewLabel").remove();
            return false;
        });

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

        $('#tb_resources').on('click', function() {
            $('#help_viewer').removeClass('hidden').dialog({
                modal:true,
                maxHeight: $('body').innerHeight() * .8,
                width: 800,
                closeOnEscape: true,
                title: 'Resources',
                position: 'center ',
                open: function() {
                    $('#compilation_tabs').tabs();
                    
                    $(".ui-dialog-titlebar-close").html("close | x").removeClass("ui-state-default");
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
                    $(".ui-dialog-titlebar-close").html("close | x").removeClass("ui-state-default");
                }
            });

            e.preventDefault();
        });

        // save
        var publishing = false;
        
        $('#tb_save').on('ajax:beforeSend', function(event, xhr, settings) {
            settings.data = $('#page-data').html();

            $('#save_prompt').stop().removeAttr('style').removeClass('hidden').css({display: 'block', zIndex: 999999999, top: 30, position: 'fixed', width: '100%', textAlign: 'center', backgroundColor: '#ffe', borderBottom: 'solid 1px #ddd'}).html('Saving...');
        });

        $('#tb_save').on('ajax:success', function(event, xhr, settings) {
            $("#save_prompt").html('saved at: ' + new Date().toLocaleTimeString()).delay(5000).fadeOut(1000);
        });

        // preview
        $('#tb_preview').click(function() {
            if($('.dialog-preview').length) {
                $('#previewWrapper').dialog('close');
            } else {

                var url = $('#tb_save').attr('href');
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

                var previewHTML = $("#container #page").children().html();
                var preview = $('#preview').html(previewHTML);

                var previewWrapper = $('#previewWrapper').clone().css({ backgroundColor: "#F5F5F5" });

                $("#preview", previewWrapper).show();
                $("#spacer", previewWrapper).show();
                $('body').addClass('dialog-preview');



                $(".content", previewWrapper).show();
                $(".example", previewWrapper).hide();

                $(".editable, .editableHtml", previewWrapper).removeClass("editable editableHtml").removeAttr("tabindex");

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

                $(".ui-dialog-titlebar-close").html("close | x").removeClass("ui-state-default").focus();
            }

            return false;
        });

        $('#extra_credit').on('blur', '.editing :input', function() {
            callbacks['updateTableSum']({ target: '#extra_credit' });
        });

        // publish
        $("#share_prompt").dialog({ modal:true, width:500, title:'Publish', autoOpen:false });
        $(".ui-dialog-titlebar-close").html("close | x").removeClass("ui-state-default").focus();
        
        $('#tb_share').on('ajax:beforeSend', function(event, xhr, settings) {
            settings.data = $('#page-data').html();

            $('#save_message').show();
            $('#pdf_share_link').hide();
            $('#share_prompt').dialog('open');
        });

        $('#tb_share').on('ajax:success', function() {
            setTimeout(
                function() {
                    $('#save_message').hide();
                    $('#pdf_share_link').removeClass('hidden').show();
                }, 15000
            );
        });

        // select course from LMS
        $("#course_prompt").dialog({ modal:true, width:500, title:'Select Course', autoOpen:false });
        $(".ui-dialog-titlebar-close").html("close | x").removeClass("ui-state-default").focus();
        
        $('#tb_share').on('ajax:beforeSend', function(event, xhr, settings) {
            settings.data = $('#page-data').html();

            $('#save_message').show();
            $('#pdf_share_link').hide();
            $('#share_prompt').dialog('open');
        });


        // table drag and drop
        $("#grade_components,#extra_credit").tableDnD({ onDragClass: "myDragClass",});

        // load the information section by default
        $("#controlPanel aside").hide();
        if ($("#edit_syllabus")) {
            $("#tabs a").first().click();
        }

        $("body").append($("<label>Edit Section Heading</label>").addClass("visuallyhidden")); // huh?

        $('#tb_save_canvas').on('ajax:beforeSend', function(){
            console.log($("#loading_courses_dialog"));
            $('#loading_courses_dialog').removeClass('hidden').dialog({modal: true, width: 500, title: "Loading from Canvas"});
            $('.ui-dialog-titlebar-close').html('close | x').removeClass('ui-state-default').focus();
        });

        $(window).on('hashchange', function() {
            $('.ui-dialog-content').dialog('close');

            if(window.location.hash === '#/resources' || window.location.hash === '#CanvasImport_tab') {
                $("#tb_resources").trigger('click');
                $('#compilation_tabs a[href="#CanvasImport_tab"]').trigger('click');
            } else if(window.location.hash == '#/select/course') {
                $("#tb_save_canvas").trigger('click');
            } else if (window.location.hash.search(/^#[a-z]+$/) === 0) {
                console.log(window.location.hash);
                $('#tabs a[href=' + window.location.hash + ']').trigger('click');
            }
        }).trigger('hashchange');
    });

    var updateGradeScale = function(grade_scale, total_points) {
        if (!grade_scale) {
            grade_scale = $('#grade_scale');
        }

        if(total_points === '-') {
            total_points = 0;
        }

        if ($('#grade_components:visible').length && total_points < 100) {
            $(grade_scale).addClass('inactive');

            $('tbody > tr > td:last-child', grade_scale).text('-');
            return false;
        };

        $(grade_scale).removeClass('inactive');

        var rows = $('tbody > tr:visible', grade_scale);
        var upper_points = total_points;

        rows.each(function(index, row){
            var cells = $('td', row);
            var parts = $(cells[1]).text().split("-");
            var percent_delta = parseInt(parts[1]) - parseInt(parts[0]);
            var points_delta = Math.round(percent_delta*total_points/100);

            lower_points = Math.round((total_points * parseInt(parts[0]))/100);

            if (isNaN(lower_points)) {
                lower_points = '';
            }

            $(cells[2]).text(lower_points + " - " + upper_points);

            upper_points = lower_points - 1;
        });

        return true;
    };

    // var updateTableSum = function(table){
    //     var total = 0;
    //     var rows = $('tbody > tr', table);
    //     rows.each(function(index, row){
    //         var points_cell = $($('td',row).last());
    //         var editing = $('input',points_cell).length > 0;
    //         var points = parseInt(editing ? $('input',points_cell).val() : points_cell.text());
    //         if (index == rows.length - 1) {
    //             points_cell.text(total);
    //         } else {
    //             total += points;
    //         }
    //     });
    // };

    var callbacks = {
        updateTableSum: function(args) {
            var dataCells = $("tbody td:last-child", args.target);
            var sum = 0;
            var value;

            dataCells.each(function(){
                if($(this).has('input').length) {
                    value = parseInt($('input', this).val());
                } else {
                    value = parseInt($(this).text());
                }

                if(value) {
                    sum += value;
                }
            });

            if(!sum) {
                sum = '-';
            }

            $("tfoot td:last-child", args.target).text(sum);

            // reapply tableDnD so new rows will be draggable
            callbacks['reapplyTableDnD'](args);

            return sum;
        },

        updateGradeScale: function(args) {
            args.target = $('#grade_components');
            var total_points = callbacks.updateTableSum(args);

            updateGradeScale($('#grade_scale'), total_points);

            // reapply tableDnD so new rows will be draggable
            callbacks['reapplyTableDnD'](args);
        },

        reapplyTableDnD: function(args) {
            $(args.target).tableDnD({ onDragClass: "myDragClass"});
        },

        fixGradeScale: function(args) {
            // if the target is not a table, set it to the closest table
            var fixed_args = $.extend({}, args);
            fixed_args.target = $(args.target).is('table') ? args.target : $(args.target).closest('table');

            // set the upper percentage of the first row in the grade table to be 100
            var first_row = $('tbody tr:visible:first .maxRange', fixed_args.target).text(100);

            // revalidate the grade scale
            callbacks.validateGradeScale(fixed_args);

            // recalculate the points column
            callbacks.updateGradeScale(fixed_args);
        },
        validateGradeScale: function(args) {

            var minRangeElements = $('tr:visible', args.target).find("span.minRange");

            $(minRangeElements).each(function(i, element){
                var new_value = parseInt($(element).text());
                var cell = $(element).closest("td");
                var parts = $(cell).find('span');
                var existingRange = {
                    min: parseInt(parts.eq(0).text()),
                    max: parseInt(parts.eq(1).text())
                };

                // don't allow a percentage that would invalidate a higher grade range
                new_value = Math.min(new_value, existingRange.max-1);

                $(element).text(new_value);

                var next_grade = $('td', cell.closest("tr").next())[1];
                parts = $(next_grade).find('span');

                var nextRange = {
                    min: parseInt(parts.eq(0).text()),
                    max: parseInt(parts.eq(1).text())
                };

                if (parts.length > 0) {
                    var new_minRange = Math.min(parseInt(nextRange.min), new_value-2);

                    $(next_grade).find('span.minRange').text(new_minRange).siblings('span').text(new_value-1);
                }

            });

            // cascade down

        }
    }

    var controlMethods = {
        toggleContent: function(args) {
            var existingElements = args.target.find(args.element);
            var visibleElements = existingElements.filter(":visible");
            var newText;

            if(args.action === "+") {

                if((args.max === undefined || visibleElements.length < args.max) && existingElements.length > visibleElements.length) {
                    var activateElement = args.target.find(args.element+":hidden").first();

                    if(activateElement.text() === '') {
                        if(args.text instanceof Array) {
                            newText = args.text[activateElement.index()];
                        } else {
                            newText = args.text;
                        }

                        activateElement.html(newText);
                    }

                    activateElement.show();
                } else if(args.max === undefined || existingElements.length < args.max) {
                    var newElement;

                    if(args.template && $(args.template, "#templates").length) {
                        newElement = $(args.template, "#templates").clone();
                        newElement.removeAttr('id');
                    } else {
                        if(args.text instanceof Array) {
                            newText = args.text[existingElements.length];
                        } else {
                            newText = args.text;
                        }
                        newElement = $("<"+args.element+"/>").html(newText);
                        if (!args.source.is('dt'))
                            newElement.addClass("editable");
                    }
                    if ($(args.target).is('table')) {
                        $('tbody', args.target).append(newElement);
                    } else {
                        args.target.append(newElement);
                    }
                }
            } else if(args.action === "-") {
                if(args.min === undefined || visibleElements.length > args.min) {
                    args.target.find(args.element+":visible").last().remove();
                }
            } else {
                args.target.toggleClass('hide');
                args.source.closest("section").toggleClass("ui-state-active ui-state-default");
            }

            // a callback was defined for this control
            if(args.callback) {
                // create a local alias to the callback method
                var callbackFunction = callbacks[args.callback];

                // if the callback method exists and is a function, execute it
                if(callbackFunction) {
                    // pass along the controlMethod's arguments to the callback
                    callbackFunction(args);
                } else {
                    console.log('callback not found', args.callback, callbackFunction);
                }
            }

            return true;
        },
        scaleCss: function(args) {
            var originalMargin = args.target.css(args.property);

            args.target.css(args.property, args.action + "=" + args.step);

            var newValue = parseFloat(args.target.css(args.property));

            if(newValue > args.max * parseFloat(args.step) || newValue < args.min * parseFloat(args.step)) {
                args.target.css(args.property, originalMargin);
            }
        },
        toggleTemplate: function(args) {
            var existingElements = args.target.children();
            var visibleElements;

            if(args.action === '+') {
                args.target.append($("#templates #" + args.template).clone());
            } else if (args.action === '-') {
                args.target.children(":visible").last().hide();
            }
        },
        taxonomy: function(args) {
            if(args.text && args.element) {
                var newArgs = $.extend({}, args);
                newArgs.action = "+";
                controlMethods.toggleContent(newArgs);

                args.text = undefined;
                args.element = undefined;
            }

            var topBar = $("<div id='topBar'><ul class='inner'/></div>");
            topBar.prepend($("<h2/>").text(args.source.text()));
            args.source.nextUntil("dt").each(function(){
                var newItem = $("<li><a href='#'/></li>");
                $("a", newItem).text($(this).text());

                newItem.appendTo($(".inner", topBar));
            })

            $("#topBar").remove();
            $("#container").before($(topBar)).css({ top: (parseInt(topBar.css("top"), 10) + parseInt(topBar.outerHeight(), 10) + 5) + "px" });

            args.source.siblings(".ui-state-active").removeClass("ui-state-active");
            args.source.addClass("ui-state-active");
        }
    };
})(jQuery);

