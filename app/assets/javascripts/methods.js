var syncViewState = function(viewSelector, viewName) {
    // remove the message to re-enable this view
    $(".enableViewMessage").remove();

    // make sure the view disable link's icon matches the state of the section
    if($(viewSelector).hasClass("disabled")) {
        $("#content_disable_link span").addClass("hidden");

        // add the message to re-enable this view
        enableViewMessage(viewName);
    } else {
        $("#content_disable_link span").removeClass("hidden");

        $("#messages .sectionDisabledMessage").stop().remove();


        var disableSectionButton = $('#content_disable_link');
        disableSectionButton.attr({onmouseover: $('#tabs .selected').attr('onmouseover') });
        disableSectionButton.attr({onmouseout: $('#tabs .selected').attr('onmouseout') });
    }
};
var focusEditor = function(editor, context) {
    return window[editor + '_focus'](context);
}

var blurEditor = function(editor, context){
    return window[editor + '_blur'](context);
};

var cleanupEditor = function(editor, context){
    return window[editor + '_cleanup'](context);
}

var initEditor = function(editor, context){
    return window[editor + '_init'](context);
}

var cleanupDocument = function(context) {
    var documentToPublish = $('<div/>').html(context);

    cleanupEditor(editor, documentToPublish);

    // force cleanup of items no document should have in them (artifacts from editor)
    $('[contenteditable],[tabindex]', documentToPublish).removeAttr('contenteditable tabindex');

    // remove other styling artifacts
    // tablednd
    $('[style="cursor: move;"]', documentToPublish).removeAttr('style');

    return documentToPublish.html();
}
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
// edit an html block

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

//Sync Section_nav with main
var sidebarList = $("#tabs").children().children("li")
var sidebarClassList = []
sidebarList.each(function(){
  sidebarClassList.push(this.classList.item(0))
})
var mainList = $("div #page-data").children("section")
mainList.each(function(){
  if(!sidebarClassList.includes(this.id)){
    $(this).addClass("disabled")
  }
})

// dynamically get all of the top level sections as an array
var sectionsNames = $('#tabs a').map(function(){
   return $(this).attr('href').replace(/^#/, '');
}).get().join().split(',');


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
    $(".ui-dialog-titlebar-close").html("close | x").removeClass("ui-button-icon-only").focus();
};

var enableViewMessage = function(view_name) {

    $("#messages .sectionDisabledMessage").stop().remove();

    // generate message
    var newMessage = $('<div class="sectionDisabledMessage"/>').html("The " + view_name + " view has been disabled.");

    // put message in message queue
    $("#messages").prepend(newMessage);

    newMessage.delay(5000).fadeOut(1000, function(){
      $(this).remove();
    });

    var enableButton = $("<button class='enable_view'></button>").text("Enable the " + view_name + " view").on("click", function(){
        $("#content_disable_link").trigger('click');
        initEditor(editor, document);
    });
    var viewMessageElement = $("<div class='enableViewMessage'></div>").append(enableButton);

    $("#container").append(viewMessageElement);
};

// save
var publishing = false;
