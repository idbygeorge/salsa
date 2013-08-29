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

        // left sidebar section selector
        $("#tabs a").on("click", function(){
            var listItem = $(this).closest("li");
            var list = listItem.closest("ul");
            
            list.find(".selected").removeClass("selected");
            $(this).closest("li").addClass("selected");
            
            var section = $(this).attr("href");
            
            $("section.active, aside.active").removeClass("active").hide();
            $(section + ", #controlPanel " + section.replace('#', '.')).addClass("active").show();
            
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
            var extra_credit = $('#extra_credit');
            if (extra_credit.has(element).length > 0) {
                updateTableSum($('#extra_credit'));
                return;
            }
            var grade_component = $('#grade_components');
            if (grade_component.has(element).length > 0)
                updateTableSum(grade_component);
            var grade_scale = $('#grade_scale');
            if (grade_scale.has(element).length > 0)
                validateGradeScale(grade_scale, element);
            updateGradeScale(grade_scale);
        };

        var updateTableSum = function(table){
            var total = 0;
            var rows = $('tbody > tr', table);
            rows.each(function(index, row){
                var points_cell = $($('td',row).last());
                var editing = $('input',points_cell).length > 0;
                var points = parseInt(editing ? $('input',points_cell).val() : points_cell.text());
                if (index == rows.length - 1) {
                    points_cell.text(total);
                } else {
                    total += points;
                }
            });
        };

        var validateGradeScale = function(grade_scale, element) {
            var new_value = parseInt(element.text());
            var cell = $(element).parent();
            var parts = $(cell).text().split('-');

            // if the element is a lower bound, ensure the next grade's upper bound is one lower
            if (new_value == parseInt(parts[0])) {
                var next_grade = $('td', cell.parent().next())[1];
                parts = $(next_grade).text().split('-');
                if (parts.length > 0)
                    $(next_grade).html('<span class="editable">' + parts[0] + '</span>-<span class="editable">' + (new_value-1) + '</span>');

            // if the element is an upper bound, ensure the previous grade's lower bound is one higher
            } else {
                var prev_grade = $('td', cell.parent().prev())[1];
                parts = $(prev_grade).text().split('-');
                if (parts.length > 0) {
                    var upper_bound = (parts[1] == ' 100') ? parts[1] : ('<span class="editable">' + parts[1] + '</span>');
                    $(prev_grade).html('<span class="editable">' + (new_value+1) + '</span>-' + upper_bound);
                }
            }
        };

        var updateGradeScale = function(grade_scale) {
            if (!grade_scale)
                grade_scale = $('#grade_scale');
            var total_points = parseInt($('#grade_components > tbody > tr:last > td:last').text());
            if (total_points < 100) return;
            var rows = $('tbody > tr', grade_scale);
            var upper_points = total_points;
            rows.each(function(index, row){
                var cells = $('td', row);
                var parts = $(cells[1]).text().split("-");
                var percent_delta = parseInt(parts[1]) - parseInt(parts[0]);
                var points_delta = Math.round(percent_delta*total_points/100);
                lower_points = upper_points - points_delta
                if (isNaN(lower_points)) lower_points = '';
                $(cells[2]).text(lower_points + " - " + upper_points);
                upper_points = lower_points - 1;
            });
        };
        
        // make stuff editable        
        $("section :header,#templates :header").addClass("editable").attr("tabindex", 0);
        $("section article .text,#templates .text").addClass("editableHtml").attr("tabindex", 0);
        
        // edit an html block
        $("section").on("click", ".editableHtml", function(){
            var element = $(this);
            var text = element.toggleClass("editableHtml editingHtml").html();
            
            element.html($("<textarea/>").attr("id", "contentTextControl").val(text)).find("textarea");
            element.append($("<div id='old_html'>" + text + '</div>'));
            
            
            $('#contentTextControl', this).tinymce({
                toolbar: "bold italic underline | undo redo | bullist numlist",
                statusbar: false,
                menubar : false,
                plugins : "autoresize,autolink",
                content_css : "/stylesheets/content.css",
                width: '300',
                height: '400',
                auto_focus: 'contentTextControl',
                setup : function(ed) {
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
            editor.keyup(function(e){
                editor.val(editor.val().replace(/\D/g, ''));
            });
        };

        // edit a simple value (no html)
        $("#page").on("click keypress", ".editable", function(){
            var text = $(this).toggleClass("editable editing").text();
            
            var editor = $(this).html($("<input/>").attr("id", "headerTextControl").val(text)).find("input");
            if ($('#grade_components').has(editor).length > 0) {
                editor.attr('maxlength',6);
                makeNumericTextbox(editor);
            }else if ($('#extra_credit').has(editor).length > 0) {
                editor.attr('maxlength',6);
                makeNumericTextbox(editor);
            }else if ($('#grade_scale').has(editor).length > 0) {
                editor.attr('maxlength',2);
                makeNumericTextbox(editor);
            }
            editor.keydown(function(e){
                var key = e.charCode ? e.charCode : e.keyCode ? e.keyCode : 0;
                if (key == 13){
                    editor.blur();
                }
            });
            editor.focus();
        });
        
        $("section").on("blur", ".editing input", function(){
            var text = $(this).val();
            var element = $(this).closest(".editing")
            if (text == "" && element.data('can-delete') == true)
                element.remove();
            else {
                element.html(text).toggleClass("editable editing");
                 if ($('#grades').has(element)) {
                    updateGradesPage(element);
                 }
             }
        });
        
        // preview control
        var previewSection = function(content_type, preview_label){
            var active_page = $('section.active').attr('id');
            return previewPage("#" + content_type +"_"+active_page, preview_label);
        };

        var previewPage = function(selector, preview_label){
            var preview = $(selector).children().clone().show();
            $(".content", preview).remove();
            $(".masthead, #wrapper, footer").hide();
            $("#preview").html(preview).show().addClass("overlay");
            $("#preview_control").show().append($("<div class='previewLabel'/>").text(preview_label));
            return false;
        };

        $("#preview_control a").on("click", function(){
            $("#preview,#preview_control").hide();
            $(".masthead, #wrapper, footer").show();
            $("#preview_control .previewLabel").remove();
            return false;
        });

        // example
        $("#tb_example").on("click", function(){
            return previewPage('#example','Example');
        });

        $("#content_example_link").on("click", function(){
            return previewSection('example','Example');
        });

        // help
        $("#tb_help").on("click", function(){
            return previewPage("#help_page",'Help');
        });

        $("#content_help_link").on("click", function(){
            return previewSection('help','Help');
        });

        // save
        var publishing = false;
        $("#save_prompt").dialog({
            modal:true, 
            height:110,
            autoOpen:false, 
            closeOnEscape: false,
            dialogClass: 'no-close'
        });
        $('#tb_save').on('ajax:beforeSend', function(event, xhr, settings) {
            if (publishing) {
                $('#saving_msg').text('Generating PDF. Just a moment....');
            } else {
                $('#saving_msg').text('Saving Syllabus. Just a moment...');
            }
            settings.data = $('#page-data').html();
            $("#save_prompt").dialog('option', 'title', (publishing ? 'Publishing Syllabus' : 'Save Syllabus'));
            $("#save_prompt").dialog("open");
        });
        $('#tb_save').on('ajax:success', function(event, xhr, settings) {
            setTimeout(function(){
                $("#save_prompt").dialog("close")
                if (publishing) {
                    $("#share_prompt").dialog("open");
                    $(".ui-widget-overlay").on("click", function (){
                      $("div:ui-dialog:visible").dialog("close");
                    });
                    publishing = false;
                }
            },(publishing ? 15000 : 1000));
        });

        // publish
        $("#share_prompt").dialog({ modal:true, width:500, title:'Your syllabus has been published!', autoOpen:false });
        $('#tb_share').click(function() { 
            publishing = true;
            $('#tb_save').first().click();
        });

        // table drag and drop
        $("#grade_components,#extra_credit").tableDnD({ onDragClass: "myDragClass",});

        // load the information section by default
        $("#controlPanel aside").hide();
        if ($("#edit_syllabus")) $("#tabs a").first().click(); 
        $("body").append($("<label>Edit Section Heading</label>").addClass("visuallyhidden")); // huh?
    });

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
                        $('tbody > tr:last', args.target).before($("tbody tr:last", newElement));
                    } else {
                        args.target.append(newElement);
                    }
                }
            } else if(args.action === "-") {
                if ($(args.target).is('table') && $('tr', args.target).length > 5) {
                    $('tbody > tr', args.target).eq(-2).remove();
                    updateTableSum(args.target);
                    updateGradeScale();
                }
                if(args.min === undefined || visibleElements.length > args.min) {
                    args.target.find(args.element+":visible").last().remove();
                }
            } else {
                args.target.toggle();
                args.source.closest("section").toggleClass("ui-state-active ui-state-default");
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

