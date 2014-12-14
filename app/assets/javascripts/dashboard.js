/*jslint browser: true, sloppy: false, eqeq: false, vars: false, maxerr: 5, indent: 4, plusplus: true */
/*global $ */

var BASE_URL = "";

(function($){

  $(function() {
    BASE_URL = $('body').data('base-url');
  });

}(jQuery));

var grandTotal = 0,
notUsingCanvasTotal = 0,
notUsingCanvasPer = 0,
usingCanvasTotal = 0,
usingCanvasPer = 0,
noSyllabusTotal = 0,
noSyllabusPer = 0,
hasSyllabusTotal = 0,
hasSyllabusPer = 0,
usedWizardTotal = 0,
usedWizardPer = 0;

function checkTotals() {
  'use strict';
  grandTotal = $(".courses li:visible").length;
  notUsingCanvasTotal = $(".courses .fa-times-circle:visible").length;
  notUsingCanvasPer = Math.floor((notUsingCanvasTotal / grandTotal) * 100);
  usingCanvasTotal = grandTotal - notUsingCanvasTotal;
  usingCanvasPer = Math.floor((usingCanvasTotal / grandTotal) * 100);
  noSyllabusTotal = $(".courses .fa-question-circle:visible").length;
  noSyllabusPer = Math.floor((noSyllabusTotal / usingCanvasTotal) * 100);
  hasSyllabusTotal = $(".courses .fa-check-circle:visible").length;
  hasSyllabusPer = Math.floor((hasSyllabusTotal / usingCanvasTotal) * 100);
  usedWizardTotal = $(".courses .icon-magic:visible").length;
  usedWizardPer = Math.floor((usedWizardTotal / usingCanvasTotal) * 100);

  $('.grandTotal').html(grandTotal);
  $('.notUsingCanvasTotal').html(notUsingCanvasTotal);
  $('.notUsingCanvasPer').html(notUsingCanvasPer + '%');
  $('.usingCanvasTotal').html(usingCanvasTotal);
  $('.usingCanvasPer').html(usingCanvasPer + '%');
  $('.noSyllabusTotal').html(noSyllabusTotal);
  $('.noSyllabusPer').html(noSyllabusPer + '%');
  $('.hasSyllabusTotal').html(hasSyllabusTotal);
  $('.hasSyllabusPer').html(hasSyllabusPer + '%');
  $('.usedWizardTotal').html(usedWizardTotal);
  $('.usedWizardPer').html(usedWizardPer + '%');

  $('#canvasUse').highcharts({
    chart: {type: 'column'},
    colors: [
    '#999999',
    '#428bca'
    ],
    title: {text: null },
    xAxis: {categories: ['Canvas Usage'] },
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
      name: 'Not In Canvas',
      data: [notUsingCanvasTotal]
    }, {
      name: 'In Canvas',
      data: [usingCanvasTotal]
    }]
  });
  $('#syllabusState').highcharts({
    chart: {type: 'column'},
    colors: [
    '#B94A48',
    '#468847'
    ],
    title: {text: null },
    xAxis: {categories: ['Syllabus Usage'] },
    yAxis: {
      min: 0,
      title: {text: '% Courses Using Canvas'}
    },
    tooltip: {
      pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b> ({point.percentage:.0f}%)<br/>',
      shared: true
    },
    plotOptions: {
      column: {stacking: 'percent'}
    },
    series: [{
      name: 'No Content in Syllabus Page',
      data: [noSyllabusTotal]
    }, {
      name: 'Content in Syllabus Page',
      data: [hasSyllabusTotal]
    }]
  });
  // Data specific to "All USU Courses"
  var collegeList = [],
  collegeTotalCourses = [],
  collegePublished = [],
  collegeUnpublished = [],
  collegeUsingSyllabus = [],
  collegeNotUsingSyllabus = [];
  $('h2').each(function () {
    collegeList.push($(this).text());
    collegeTotalCourses.push($(this).parents(".college-list").find('li:visible').length);
    collegePublished.push($(this).parents(".college-list").find('.using-canvas:visible').length);
    collegeUnpublished.push($(this).parents(".college-list").find('.not-using-canvas:visible').length);
    collegeUsingSyllabus.push($(this).parents(".college-list").find('.fa-check-circle:visible').length);
    collegeNotUsingSyllabus.push($(this).parents(".college-list").find('.fa-question-circle:visible').length);
    var myClass = $(this).index();

    $(this).before('<a name="' + myClass + '"></a>');
    $(this).append('<a class="topLink" href="#top"><i class="icon-circle-arrow-up"></i> Top</a>');
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
      name: 'No Content in Syllabus Page',
      data: collegeNotUsingSyllabus
    }, {
      name: 'Content in Syllabus Page',
      data: collegeUsingSyllabus
    }, {
      name: 'Courses Published',
      data: collegePublished
    }, {
      name: 'Courses UnPublished',
      data: collegeUnpublished
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
