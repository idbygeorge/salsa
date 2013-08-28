/* Author: John Pope
 * Utah State University - 2012
*/

function showPreview(){
    var preview = $("#page-data").children().clone().show();
    $(".content", preview).hide();
    $(".example", preview).show();
    
    $(".editable, .editableHtml", preview).removeClass("editable editableHtml").removeAttr("tabindex");
    
    $("#preview").html(preview).show().addClass("overlay");
    $("#preview_control").show().append($("<div class='previewLabel'/>").text($(this).text()));

    $(".masthead, #wrapper, footer").hide();
}

function liteOnI(x){
    x.style.backgroundColor="#ccc";
}
function liteOnO(x){
    x.style.backgroundColor="#d6f0ff";
}
function liteOnR(x){
    x.style.backgroundColor="#eff67d";
}
function liteOnA(x){
    x.style.backgroundColor="#e0ff95";
}
function liteOnP(x){
    x.style.backgroundColor="#d8d8ff";
}
function liteOnG(x){
    x.style.backgroundColor="#f8ffea";
}
function liteOff(x){
    x.style.backgroundColor="#fff";
}

(function($) {
    $(function(){ 
        $("body").append($("<label>Edit Section Heading</label>").addClass("visuallyhidden"));
        $("#controlPanel aside").hide();
        
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
        
        $("section :header,#templates :header").addClass("editable").attr("tabindex", 0);
        $("section article .text,#templates .text").addClass("editableHtml").attr("tabindex", 0);
        
        $("#page").on("click keypress", ".editable", function(){
            var text = $(this).toggleClass("editable editing").text();
            
            var editor = $(this).html($("<input/>").attr("id", "headerTextControl").val(text)).find("input");
            editor.keydown(function(e){
                var key = e.charCode ? e.charCode : e.keyCode ? e.keyCode : 0;
                if (key == 13){
                    editor.blur();
                }
            });
            editor.focus();
        });
        
        $("section").on("click", ".editableHtml", function(){
            var text = $(this).toggleClass("editableHtml editingHtml").html();
            
            $(this).html($("<textarea/>").attr("id", "contentTextControl").val(text)).find("input,textarea");
            
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
        
        $("section").on("blur", ".editing input", function(){
            var text = $(this).val();
            var element = $(this).closest(".editing")
            element.html(text).toggleClass("editable editing");
             if ($('#grades').has(element)) {
                controlMethods.updateGradesPage(element);
             }
        });
        
        $("section").on("blur", ".editingHtml textarea", function(){
             var html = $(this).val();
             $(this).closest(".editingHtml").html(html).toggleClass("editableHtml editingHtml");
        });
                
        $("#controlPanel").on("click", "input,dt", function() {
            var result = "";
            var controlParent = $(this).closest("[data-method]");
            var control = controlParent.data();

            control.source = $(this);
            if(!control.original_target) {
                $(control.source).closest("[data-target]").data("[original_target]", control.target);
            }
            control.target = getTarget(this);
            control.action = $(this).val();


            result = controlMethods[control.method](control);
            
            return false;
        });
        
        $("#tb_example").on("click", function(){
            var preview = $("#example").children().clone().show();
            $(".content", preview).hide();
            $("#preview").html(preview).show().addClass("overlay");
            $("#preview_control").show().append($("<div class='previewLabel'/>").text($(this).text()));
            $(".masthead, #wrapper, footer").hide();
            return false;
        });
        
        $(".masthead a.preview").on("click", function(){
            showPreview();
            return false;
        });

        $("#preview_control a").on("click", function(){
            $("#preview,#preview_control").hide();
            $(".masthead, #wrapper, footer").show();
            $("#preview_control .previewLabel").remove();
            return false;
        });
        if ($("#edit_syllabus")) $("#tabs a").first().click();

        $('#tb_save').on('ajax:beforeSend', function(event, xhr, settings) {
          settings.data = $('#page-data').html();
        });
        $('#tb_save').on('ajax:success', function(event, xhr, settings) {
            setTimeout(function(){$.unblockUI();}, 1000); 
        });

        $('#tb_save').click(function() { 
            $.blockUI({ message: '<br/><h1><img src="/assets/busy.gif" /> Saving. Just a moment...</h1>', css: { height: '60px'}  } ); 
        });
        $('#tb_share').click(function() { 
            $.blockUI({ message: $('#share_prompt'), css: { width: '550px', height: '150px' }  }); 
        });

        $('#prompt_close').click(function(){$.unblockUI();});
        $('#prompt_visit').click(function(){window.open($('#view_url').text(), '_blank');});

        $("#grade_components").tableDnD({
            onDragClass: "myDragClass",
        });
        $("#table2").tableDnD({
            onDragClass: "myDragClass",
        });
        $("#table3").tableDnD({
            onDragClass: "myDragClass",
        });
        $("#table4").tableDnD({
            onDragClass: "myDragClass",
        });

    });
    
    var getTarget = function(source) {
        var targetSelector = "";
        var target = $(source).closest("[data-target]").data("target");
        
        // if the target is a string, it is a selector, if it is an object, it is already set to the right element(s)
        if(typeof(target) !== "string" && target.length) { 
            if(!target.closest("body").length) {
                target = $(source).closest("[data-target]").data("[original_target]");
            } else {
                return $(target);
            }
        }
        
        $(source).parents("[data-target]").each(function(){
            targetSelector = $(this).data("target") + " " + targetSelector;
        });
        
        return $(targetSelector); 
    };
    
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
                        newElement = $("<"+args.element+"/>").html(newText).addClass("editable")
                    }
                    if ($(args.target).is('table')) {
                        $('tbody > tr:last', args.target).before($("tbody tr:last", newElement));
                        controlMethods.updateGradeScales();
                    } else {
                        args.target.append(newElement);
                    }
                }
            } else if(args.action === "-") {
                if ($(args.target).is('table') && $('tr', args.target).length > 5) {
                    $('tbody > tr', args.target).eq(-2).remove();
                    controlMethods.updateGradeScales();
                }
                if(args.min === undefined || visibleElements.length > args.min) {
                    args.target.find(args.element+":visible").last().hide();
                }
            } else {
                args.target.toggle();
                args.source.closest("section").toggleClass("ui-state-active ui-state-default");
            }
            
            return true;
        }, scaleCss: function(args) {
            var originalMargin = args.target.css(args.property);

            args.target.css(args.property, args.action + "=" + args.step);
            
            var newValue = parseFloat(args.target.css(args.property));

            if(newValue > args.max * parseFloat(args.step) || newValue < args.min * parseFloat(args.step)) {
                args.target.css(args.property, originalMargin);
            }
        }, toggleTemplate: function(args) {
            var existingElements = args.target.children();
            var visibleElements;
            
            if(args.action === '+') {
                args.target.append($("#templates #" + args.template).clone());
            } else if (args.action === '-') {
                args.target.children(":visible").last().hide();
            }
        }, taxonomy: function(args) {
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
        },
        updateGradesPage: function(element){
            var extra_credit = $('#extra_credit');
            if (extra_credit.has(element).length > 0) {
                this.updateTableSum($('#extra_credit'));
                return;
            }
            var grade_component = $('#grade_components');
            if (grade_component.has(element).length > 0)
                this.updateTableSum(grade_component);
            var grade_scale = $('#grade_scale');
            if (grade_scale.has(element).length > 0)
                this.validateGradeScale(grade_scale, element);
            this.updateGradeScale(grade_scale);
        },
        updateTableSum: function(table){
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
        },
        validateGradeScale: function(grade_scale, element) {
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
                if (parts.length > 0)
                    $(prev_grade).html('<span class="editable">' + (new_value+1) + '</span>-<span class="editable">' + parts[1] + '</span>');
            }
        },
        updateGradeScale: function(grade_scale) {
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
        }
    };
})(jQuery);

