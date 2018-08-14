var updateGradeScale = function(grade_scale, total_points) {
    if (!grade_scale) {
        grade_scale = $('#grade_scale');
    }

    if(total_points === '-') {
        total_points = 0;
    }

    var requiredPoints = 0;

    if(!$('#gradeUnitsPercent').is(':checked') && $('[data-grades-scale-required-points]').length == 1) {
        requiredPoints = $('[data-grades-scale-required-points]').data('grades-scale-required-points');
    }

    if ((requiredPoints != 0 && requiredPoints != total_points) || (($('#grade_components:visible').length && total_points < 100) || ($('#gradeUnitsPercent').is(':checked') && total_points != 100))) {
        $(grade_scale).addClass('inactive');

        $('tbody > tr > td:last-child', grade_scale).text('-');
        return false;
    };

    $(grade_scale).removeClass('inactive');

    var rows = $('tbody > tr:visible', grade_scale);
    var upper_points = total_points;

    rows.each(function(index, row){
        var cells = $('td', row);
        var parts = $(cells[1]).text().split("-");
        var percent_delta = parseInt(parts[1]) - parseInt(parts[0]);
        var points_delta = Math.round(percent_delta*total_points/100);

        lower_points = Math.round((total_points * parseInt(parts[0]))/100);

        if (isNaN(lower_points)) {
            lower_points = '';
        }

        $(cells[2]).text(lower_points + " - " + upper_points);

        upper_points = lower_points - 1;
    });

    return true;
};

var updateGradesPage = function(element){
    var args = {
        target: $('#grade_components')
    };

    var grade_scale = $('#grade_scale');

    if(grade_scale.has(element).length) {
        callbacks['validateGradeScale']({ target: grade_scale });
    }

    callbacks.updateGradeScale(args);
    return;
};
