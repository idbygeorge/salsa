// "Edit your SALSA" button for Canvas LMS
// Using a custom instance of Salsa? --> In variable salsaLink, replace 'http://salsa.usu.edu/SALSA/' with the URL to YOUR custom instance.
// Example: salsaLink = 'http://myschool.salsa.usu.edu/SALSA/' + salsaID;
// Paste JavaScript into your Canvas global JS file

// Store Canvas course number in a variable

///////////////////////////////////
// SALSA Code
///////////////////////////////////

$(document).ready(function() {

  // only run if we are on the syllabus page and there is a button to edit the syllabus showing up
  if($('#course_syllabus').length && $('.salsaLink').length) {
    // wrap in an anonymous function to avoid polluting the global namespace
    (function() {
      var printLink = $('#salsa_document_view_link').attr('href');
      var documentToken = null;
      var getDocumentTokenPattern = /.+\/SALSA\/(.+)$/;

      if(printLink && printLink.search(getDocumentTokenPattern) === 0) {
        documentToken = printLink.replace(getDocumentTokenPattern, "$1");
      }



      // array of course IDs that will use Salsa instead of the syllabus editor in Canvas
      // add course IDs to this array to enable Salsa for them
      var coursesUsingSalsa = [
	'88611'
      // Example:
      // '1297671'

      ];


      // array of term names that will use Salsa instead of the syllabus editor in Canvas
      // add term names to this array to enable Salsa for them
      var termsUsingSalsa = [

      // Example:
      // 'Fall 2016-Lx'

      ];

      // enables link by default unless term/course is blacklisted in array
      var addSalsaLinkByDefault = false

      // array of course IDs that will not use Salsa
      // add course IDs to this array to disable Salsa for them
      var coursesNotUsingSalsa = [
        '886111'
      // Example:
      // '1297671'

      ];

      // array of term names that will not use Salsa
      // add term names to this array to disable Salsa for them
      var termsNotUsingSalsa = [

      // Example:
      // 'Fall 2016-Lx'

      ];



      // get the course number from the URL
      var coursenum = location.pathname.replace(/.*\/courses\/(\d+)(\/.*)?/, '$1');

      //get the term number from the subtitle
      var termnum = $("#section-tabs-header-subtitle").text();
      var whiteListCheck = ($.inArray(coursenum, coursesUsingSalsa) !== -1 || $.inArray(termnum, termsUsingSalsa) !== -1)
      var blackListCheck = (!($.inArray(coursenum, coursesNotUsingSalsa || $.inArray(termnum, termsNotUsingSalsa) !== -1) !== -1))
      // only replace the syllabus link if this term is using Salsa or the course is whitelisted
      if ( (!addSalsaLinkByDefault && whiteListCheck && blackListCheck) || (addSalsaLinkByDefault && blackListCheck)) {
        // strings to use when building the Salsa link
        // Example: http://example.syllabustool.com/lms/courses/. Replace "example" on the next line.
        var salsaDocumentUrl = 'http://lvh.me:3000/lms/courses/' + coursenum;

        if(documentToken) {
          salsaDocumentUrl +=  '?document_token='+documentToken;
        }

        var salsaDocumentLinkText = 'Edit My SALSA';

        // add the salsa edit link
        $('.edit_syllabus_link').before(
          $('<a/>').addClass('btn salsaLink button-sidebar-wide').attr({
            'href': salsaDocumentUrl,
            'data-tooltip': 'top',
            'title': 'Button will open in a new tab',
            'target': '_blank'
          }).append(
            $('<img>').attr({
              'src': 'https://raw.githubusercontent.com/idbygeorge/salsa/master/public/img/salsa_icon.png'
            })
          ).append(' ' + salsaDocumentLinkText)
        ).remove();//  remove the button in Canvas that allows users to edit the HTML
      }

    }());
  }
});
///////////////////////////////////
// End SALSA Code
///////////////////////////////////
