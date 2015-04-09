function tinyMCE_focus(context) {
    var editorMaxHeight = jQuery('body').innerHeight() * .8;

    var element = $(context);
    var text = element.toggleClass("editableHtml editingHtml").attr('contenteditable', true).html();
    var id = "contentTextControl";

    //element.html($("<textarea/>").attr("id", id).val(text)).find("textarea");
    //element.append($("<div id='old_html'>" + text + '</div>'));

    tinymce.init({
        selector: element,
        toolbar: "bold italic | undo redo | bullist numlist indent outdent | link unlink",
        //inline: true,
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
                jQuery(".editingHtml textarea").blur();
            });
        }
    });
}

function tinyMCE_blur(context) {
    //var html = jQuery(context).val();
    
    //if (html.length == 0) {
    //    html = jQuery('#old_html').html();
    //}

    tinymce.remove(element);

    //var element = jQuery(context).closest(".editingHtml");
    //element.html(html);
    element.toggleClass("editableHtml editingHtml");
}

function tinyMCE_cleanup(context) {

}

function tinyMCE_init(context) {

}