/*jslint browser: true, sloppy: false, eqeq: false, vars: false, maxerr: 5, indent: 4, plusplus: true */
/*global $ */

var BASE_URL = "";

(function($){

  $(function() {
    BASE_URL = $('body').data('base-url');
  });

}(jQuery));

var grandTotal = 0,
usingSalsaTotal = 0,
salsaUsagePercent = 0,
notUsingSalsaTotal = 0,
notUsingSalsaPercent = 0,
noSyllabusTotal = 0,
noSyllabusPer = 0,
hasSyllabusTotal = 0,
hasSyllabusPer = 0,
usedWizardTotal = 0,
usedWizardPer = 0;

function checkTotals() {
  'use strict';
  grandTotal = $(".courses li:visible").length;
  usingSalsaTotal = $(".courses .using-salsa:visible").length;
  salsaUsagePercent = Math.floor((usingSalsaTotal / grandTotal) * 100);
  notUsingSalsaTotal = grandTotal - usingSalsaTotal;
  notUsingSalsaPercent = Math.floor((notUsingSalsaTotal / grandTotal) * 100);
  hasSyllabusTotal = $(".courses .fa-check-circle:visible").length;
  noSyllabusTotal = usingSalsaTotal - hasSyllabusTotal;
  noSyllabusPer = usingSalsaTotal>0?Math.floor((noSyllabusTotal / usingSalsaTotal) * 100):0;
  hasSyllabusPer = usingSalsaTotal>0?Math.floor((hasSyllabusTotal / usingSalsaTotal) * 100):0;
  usedWizardTotal = $(".courses .icon-magic:visible").length;
  usedWizardPer = Math.floor((usedWizardTotal / notUsingSalsaTotal) * 100);

  $('.grandTotal').html(grandTotal);
  $('.usingSalsaTotal').html(usingSalsaTotal);
  $('.salsaUsagePercent').html(salsaUsagePercent + '%');
  $('.notUsingSalsaTotal').html(notUsingSalsaTotal);
  $('.notUsingSalsaPercent').html(notUsingSalsaPercent + '%');
  $('.noSyllabusTotal').html(noSyllabusTotal);
  $('.noSyllabusPer').html(noSyllabusPer + '%');
  $('.hasSyllabusTotal').html(hasSyllabusTotal);
  $('.hasSyllabusPer').html(hasSyllabusPer + '%');
  $('.usedWizardTotal').html(usedWizardTotal);
  $('.usedWizardPer').html(usedWizardPer + '%');

  $('#canvasUse').highcharts({
    chart: {type: 'column'},
    colors: [
    '#428bca',
    '#999999'
    ],
    title: {text: null },
    xAxis: {categories: ['Salsa Usage'] },
    yAxis: {
      min: 0,
      title: {text: 'Course Percentage'}
    },
    tooltip: {
      pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b> ({point.percentage:.0f}%)<br/>',
      shared: true
    },
    plotOptions: {
      column: {stacking: 'percent'}
    },
    series: [{
      name: 'Using Salsa',
      data: [usingSalsaTotal]
    }, {
      name: 'Not Using Salsa',
      data: [notUsingSalsaTotal]
    }]
  });
  $('#syllabusState').highcharts({
    chart: {type: 'column'},
    colors: [
    '#B94A48',
    '#468847'
    ],
    title: {text: null },
    xAxis: {categories: ['Published Salsas'] },
    yAxis: {
      min: 0,
      title: {text: '% Published'}
    },
    tooltip: {
      pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b> ({point.percentage:.0f}%)<br/>',
      shared: true
    },
    plotOptions: {
      column: {stacking: 'percent'}
    },
    series: [{
      name: 'Not Published in Canvas',
      data: [noSyllabusTotal]
    }, {
      name: 'Published in Canvas',
      data: [hasSyllabusTotal]
    }]
  });
  // Data specific to "All USU Courses"
  var collegeList = [],
  collegeTotalCourses = [],
  collegeUsingSalsa = [],
  collegeNotUsingSalsa = [],
  collegeUsingSyllabus = [],
  collegeNotUsingSyllabus = [];
  $('h2:visible').each(function () {
    $('.topLink', this).remove();
    collegeList.push($(this).text());
    collegeTotalCourses.push($(this).parents(".college-list").find('li:visible').length);
    collegeUsingSalsa.push($(this).parents(".college-list").find('.using-salsa:visible').length);
    collegeNotUsingSalsa.push($(this).parents(".college-list").find('.not-using-salsa:visible').length);
    collegeUsingSyllabus.push($(this).parents(".college-list").find('.using-salsa.has-syllabus:visible').length);
    collegeNotUsingSyllabus.push($(this).parents(".college-list").find('.using-salsa.no-syllabus:visible').length);
    var myClass = $(this).index();

    if(!$(this).has('.topLink').length) {
      $(this).before('<a name="' + myClass + '"></a>');
      $(this).append('<a class="topLink" href="#top"><i class="icon-circle-arrow-up"></i></a>');
    }
  });
  $('#collegeCount').highcharts({
    chart: {type: 'bar'},
    colors: [
    '#B94A48',                '#468847',
    '#428bca',
    '#999999',                '#000000'
    ],
    title: {
      text: 'Canvas Usage'
    },
    subtitle: {
      text: 'By College (Based on courses with student enrollments)'
    },
    xAxis: {
      categories: collegeList,
      title: {text: null }
    },
    yAxis: {
      min: 0,
      title: {
        text: 'Number of Courses',
        align: 'high'
      },
      labels: {overflow: 'justify'}
    },
    tooltip: {valueSuffix: ' Courses'},
    plotOptions: {
      bar: {
        dataLabels: {
          enabled: true
        }
      }
    },
    legend: {
      layout: 'vertical',
      align: 'right',
      verticalAlign: 'top',
      x: -40,
      y: 100,
      floating: true,
      borderWidth: 1,
      backgroundColor: '#FFFFFF',
      shadow: true
    },
    credits: {
      enabled: false
    },
    series: [{
      name: 'Unpublished SALSAs',
      data: collegeNotUsingSyllabus
    }, {
      name: 'Published SALSAs',
      data: collegeUsingSyllabus
    }, {
      name: 'Using Salsa',
      data: collegeUsingSalsa
    }, {
      name: 'Not Using Salsa',
      data: collegeNotUsingSalsa
    }, {
      name: 'Total Courses',
      data: collegeTotalCourses
    }]
  });
}
$(function () {
  'use strict';
  $("[data-toggle=tooltip]").tooltip({html: true});
  checkTotals();
  $('.expandList').click(function (e) {
    e.preventDefault();
    $('.collapseList').removeClass('active');
    $(this).addClass('active');
    $('.panel-collapse').each(function () {
      $(this).addClass('in');
    });
  });
  $('.collapseList').click(function (e) {
    e.preventDefault();
    $('.expandList').removeClass('active');
    $(this).addClass('active');
    $('.panel-collapse').each(function () {
      $(this).removeClass('in');
    });
  });
});

(function($){
  var accountFilter = $('#account_filters').on('change', function(){
    var activeAccount = $('#account_'+this.value);

    if(activeAccount.closest('.department').length) {
      var department = activeAccount;
      activeAccount = department.closest('.college-list');

      if(department.length) {
        $('.department', activeAccount).not(department).hide();
        department.show();
      } else {
        $('.department', activeAccount).show();
      }
    } else {
      $('.department').show();
    }

    if(activeAccount.length) {
      $('.college-list').not(activeAccount).hide();
      activeAccount.show();
    } else {
      $('.college-list').show();
    }

    checkTotals();
  });
  var accountElms = $('h2,h3','.college-list');

  accountElms.each(function(accountElm){
    var account = $(this).data('account');
    var styling = '';

    if($(this).closest('.department').length) {
      styling = '&nbsp; &nbsp;';
    }

    accountFilter.append('<option value="' + account.id + '">' + styling + account.name + '</option>');
  });

}(jQuery));
