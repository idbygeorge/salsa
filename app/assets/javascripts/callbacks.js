    var callbacks = {
        updateTableSum: function(args) {
            var dataCells = $("tbody td:last-child", args.target);
            var sum = 0;
            var value;

            dataCells.each(function(){
                if($(this).has('input').length) {
                    value = parseInt($('input', this).val());
                } else {
                    value = parseInt($(this).text());
                }

                if(value) {
                    sum += value;
                }
            });

            if(!sum) {
                sum = '-';
            }

            $("tfoot td:last-child", args.target).text(sum);

            // reapply tableDnD so new rows will be draggable
            callbacks['reapplyTableDnD'](args);

            return sum;
        },

        updateGradeScale: function(args) {
            args.target = $('#grade_components');
            var total_points = callbacks.updateTableSum(args);

            updateGradeScale($('#grade_scale'), total_points);

            // reapply tableDnD so new rows will be draggable
            callbacks['reapplyTableDnD'](args);
        },

        reapplyTableDnD: function(args) {
            $(args.target).tableDnD({ onDragClass: "myDragClass"});
        },

        fixGradeScale: function(args) {
            // if the target is not a table, set it to the closest table
            var fixed_args = $.extend({}, args);
            fixed_args.target = $(args.target).is('table') ? args.target : $(args.target).closest('table');

            // set the upper percentage of the first row in the grade table to be 100
            var first_row = $('tbody tr:visible:first .maxRange', fixed_args.target).text(100);

            // revalidate the grade scale
            callbacks.validateGradeScale(fixed_args);

            // recalculate the points column
            callbacks.updateGradeScale(fixed_args);
        },
        validateGradeScale: function(args) {

            var minRangeElements = $('tr:visible', args.target).find("span.minRange");

            $(minRangeElements).each(function(i, element){
                var new_value = parseInt($(element).text());
                var cell = $(element).closest("td");
                var parts = $(cell).find('span');
                var existingRange = {
                    min: parseInt(parts.eq(0).text()),
                    max: parseInt(parts.eq(1).text())
                };

                // don't allow a percentage that would invalidate a higher grade range
                new_value = Math.min(new_value, existingRange.max-1);

                $(element).text(new_value);

                var next_grade = $('td', cell.closest("tr").next())[1];
                parts = $(next_grade).find('span');

                var nextRange = {
                    min: parseInt(parts.eq(0).text()),
                    max: parseInt(parts.eq(1).text())
                };

                if (parts.length > 0) {
                    var new_minRange = Math.min(parseInt(nextRange.min), new_value-2);

                    $(next_grade).find('span.minRange').text(new_minRange).siblings('span').text(new_value-1);
                }

            });

            // cascade down

        }
    };
