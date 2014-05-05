function tinyMCE_init(context) {
    var editorMaxHeight = $('body').innerHeight() * .8;

    var element = $(context);
    var text = element.toggleClass("editableHtml editingHtml").html();
    var id = "contentTextControl";

    element.html($("<textarea/>").attr("id", id).val(text)).find("textarea");
    element.append($("<div id='old_html'>" + text + '</div>'));

    $('#' + id, context).tinymce({
        toolbar: "bold italic | undo redo | bullist numlist indent outdent | link unlink",
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
}

function tinyMCE_destroy(context) {
    var html = $(context).val();
    
    if (html.length == 0) {
        html = $('#old_html').html();
    }

    var element = $(context).closest(".editingHtml");
    element.html(html);
    element.toggleClass("editableHtml editingHtml");
}