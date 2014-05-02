function tinyMCE_init(selector, context) {
    var editorMaxHeight = $('body').innerHeight() * .8;

    $(selector, context).tinymce({
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