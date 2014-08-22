//= require jquery
//= require jquery_ujs
//= require bootstrap

$(function(){
  $('#toggleChecked').on('click', function() {
    var isChecked = $('#salsaDocuments :checkbox:first').is(':checked');
    
    console.log($('#salsaDocuments :checkbox:first').prop('checked'));

    if(isChecked) {
      $('#salsaDocuments :checkbox').prop('checked', false);
    } else {
      $('#salsaDocuments :checkbox').prop('checked', true);
    }

    return false;
  });
})