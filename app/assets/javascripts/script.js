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
            
            $(this).html($("<input/>").attr("id", "headerTextControl").val(text)).find("input,textarea").focus();
        });
        
        $("section").on("click keypress", ".editableHtml", function(){
            var text = $(this).toggleClass("editableHtml editingHtml").html();
            
            $(this).html($("<textarea/>").attr("id", "contentTextControl").val(text)).find("input,textarea");
            
            $("textarea", this).tinymce({
                script_url : '/assets/libs/tiny_mce/tiny_mce.js',
                theme : "simple",
                plugins : "autoresize,autolink",
                width: '100%',
                content_css : "/assets/content.css",
                setup : function(ed) {
                    ed.onInit.add(function(ed, evt) {
                        var dom = tinymce.dom;
                        var doc = ed.getWin();
                        
                        ed.focus();
                    
                        dom.Event.add(doc, 'blur', function(e) {
                            // Do something when the editor window is blured.
                            ed.remove();
                            
                            $(".editingHtml textarea").blur();
                        });
                    });
                }
            });
        });
        
        $("section").on("blur", ".editing input, .editing textarea", function(){
            var text = $(this).val();
            
            var elm = $(this).closest(".editing").html(text).toggleClass("editable editing");
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
                    } else {
                        if(args.text instanceof Array) {
                            newText = args.text[existingElements.length];
                        } else {
                            newText = args.text;
                        }
                        newElement = $("<"+args.element+"/>").html(newText).addClass("editable")
                    }
                    
                    args.target.append(newElement);
                }
            } else if(args.action === "-") {
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
        }
    };
})(jQuery);


$('#tb_save').on('ajax:beforeSend', function(event, xhr, settings) {
  settings.data = $('#page-data').html();
});
$('#tb_save').on('ajax:success', function(event, xhr, settings) {
    setTimeout(function(){$.unblockUI();}, 1000); 
});

$(document).ready(function() { 
    $('#tb_save').click(function() { 
        $.blockUI({ message: '<h1><img src="/assets/busy.gif" /> Saving. Just a moment...</h1>' }); 
    });
    $('#tb_share').click(function() { 
        $.blockUI({ message: $('#share_prompt'), css: { width: '550px', height: '110px' }  }); 
    });
    $('#prompt_close').click(function(){$.unblockUI();});
    $('#prompt_visit').click(function(){window.open($('#view_url').text(), '_blank');});
}); 