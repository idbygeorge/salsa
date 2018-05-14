var controlMethods = {
    toggleContent: function(args) {
        var existingElements = args.target.find(args.element);
        var visibleElements = existingElements.filter(":visible");
        var newText;
        var element;

        if(args.action === "+") {

            if((args.max === undefined || visibleElements.length < args.max) && existingElements.length > visibleElements.length) {
                var activateElement = args.target.find(args.element+":hidden").first();

                if(activateElement.text() === '') {
                    if(args.text instanceof Array) {
                        newText = args.text[activateElement.index()];
                    } else {
                        newText = args.text;
                    }

                    activateElement.html(newText);
                }

                activateElement.show().removeClass('hide');

                element = activateElement;
            } else if(args.max === undefined || existingElements.length < args.max) {
                var newElement;

                if(args.template && $(args.template, "#templates").length) {
                    newElement = $(args.template, "#templates").clone();
                    newElement.removeAttr('id');

                    $(".editableHtml,.editable", newElement).attr({ tabIndex: 0 });
                } else {
                    if(args.text instanceof Array) {
                        newText = args.text[existingElements.length];
                    } else {
                        newText = args.text;
                    }
                    newElement = $("<"+args.element+"/>").html(newText);
                    if (!args.source.is('dt'))
                        newElement.addClass("editable");
                }
                if ($(args.target).is('table')) {
                    $('tbody', args.target).append(newElement);
                } else {
                    args.target.append(newElement);
                }

                element = newElement;
            }
        } else if(args.action === "-") {
            if(args.min === undefined || visibleElements.length > args.min){
                var target = args.target.find(args.element+":visible").last()
                $("#controlPanel").contents().find( "[data-meta='"+target.data('meta')+"']").prevAll("dt").first().addClass("ui-state-default").removeClass("ui-state-disabled")
                target.remove();
                $('aside:visible:has([data-method="taxonomy"][data-unique])', "#controlPanel").find("dt.ui-state-active").trigger("click")
            }
        } else {
            args.target.toggleClass('hide');
            args.source.closest("section").toggleClass("ui-state-active ui-state-default");

            element = args.target;
        }

        if(args.meta) {
            $(element).attr('data-meta', args.meta);
        }

        if(args.editable) {
            $(element).addClass('editable', true);
        }

        // a callback was defined for this control
        if(args.callback) {
            // create a local alias to the callback method
            var callbackFunction = callbacks[args.callback];

            // if the callback method exists and is a function, execute it
            if(callbackFunction) {
                // pass along the controlMethod's arguments to the callback
                callbackFunction(args);
            } else {
                console.log('callback not found', args.callback, callbackFunction);
            }
        }

        return true;
    },
    scaleCss: function(args) {
        var originalMargin = args.target.css(args.property);

        args.target.css(args.property, args.action + "=" + args.step);

        var newValue = parseFloat(args.target.css(args.property));

        if(newValue > args.max * parseFloat(args.step) || newValue < args.min * parseFloat(args.step)) {
            args.target.css(args.property, originalMargin);
        }
    },
    toggleTemplate: function(args) {
        var existingElements = args.target.children();
        var visibleElements;

        if(args.action === '+') {
            args.target.append($("#templates #" + args.template).clone());
        } else if (args.action === '-') {
            args.target.children(":visible").last().hide();
        }
    },
    radiodropdown: function(args) {

        var option = $('input[name=choose]:checked').val()
        args.source.parent().contents().find("dt").each(function(){
          $(this).hide();
          if ($(this).is("#"+option) || $(this).is(".dropbtn")){
            $(this).show();
          }
        });

    },
    taxonomy: function(args) {
        if(args.text && args.element) {
            var newArgs = $.extend({}, args);
            newArgs.action = "+";
            controlMethods.toggleContent(newArgs);

            args.text = undefined;
            args.element = undefined;
        }
        var list = args.source.nextUntil("dt");
        if(list.length == 0) {
            return;
        }

        var topBar = $("<div id='topBar'><ul class='inner'/></div>");
        topBar.data('context', args);
        topBar.prepend($("<h2/>").text(args.source.text()));

        list.each(function(){
            if ( !args.unique || (args.unique && $("#container").contents().find( "[data-meta='"+$(this).data('meta')+"']" ).length == 0)) {
                var newItem = $("<li><a href='#'/></li>");
                $("a", newItem).text($(this).text()).attr('data-meta', $(this).data('meta'));
                newItem.appendTo($(".inner", topBar));
            }

        });

        $("#topBar").remove();
        $("#container").before($(topBar)).css({ top: (parseInt(topBar.css("top"), 10) + parseInt(topBar.outerHeight(), 10) + 5) + "px" });

        if(args.uiClass) {
            topBar.addClass(args.uiClass);
        }

        if(args.unique) {
            topBar.data('unique', args.unique);
        }

        args.source.siblings(".ui-state-active").removeClass("ui-state-active");
        args.source.addClass("ui-state-active");
    },
    specifyGradingUnits: function(args) {
        if(args.action === 'points') {
            $('th:last', args.target).text('Points');
            $('tr.total td:first-child', args.target).text('Total Points');
            $('th:last-child,td:last-child', '#grade_scale').show();
        }
        else if(args.action === 'percent') {
            $('th:last', args.target).text('Percentage');
            $('tr.total td:first-child', args.target).text('Total');
            $('th:last-child,td:last-child', '#grade_scale').hide();
        }

        updateGradeScale($('#grade_scale'), $('#grade_components .total td:last').text());
    }
};
