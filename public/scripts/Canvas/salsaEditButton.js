// "Edit your SALSA" button for Canvas LMS
// Using a custom instance of Salsa? --> In variable salsaLink, replace 'http://salsa.usu.edu/SALSA/' with the URL to YOUR custom instance.
// Example: salsaLink = 'http://myschool.salsa.usu.edu/SALSA/' + salsaID;
// Paste JavaScript into your Canvas global JS file

// Store Canvas course number in a variable

var coursenum, matches, killspot;
coursenum = null;
matches = location.pathname.match(/\/courses\/(.*)/);
if (matches) {
    coursenum = matches[1];
    killspot = coursenum.indexOf("/", 0);
    if (killspot >= 0) {
        coursenum = coursenum.slice(0, killspot);
    }
}

(function($) {

    $(function(){

        if ($('.edit_syllabus_link').length > 0 && $('a:contains("SALSA HTML")').length > 0) {

            var salsaID = $(".content").attr('id'),
                salsaLink = 'http://salsa.usu.edu/SALSA/' + salsaID;

            $('.edit_syllabus_link').before('<a class="btn salsaLink button-sidebar-wide" href="/courses/' + coursenum + '/wiki/edit-gui-salsa" data-tooltip="top" title="Button will open in a new tab" target="_blank"><img src="https://raw.githubusercontent.com/oasis4hedev/salsa/master/public/img/salsa_icon.png"> Edit My SALSA</a>');
        }

        if ($('a:contains("Edit your SALSA")').length > 0){
            document.location.href = $('a:contains("Edit your SALSA")').attr('href');
        }
    });

}());
