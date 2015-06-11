/**
 * Created by cbolanos on 12/24/2014.
 */

//$(document).ready(function() {
//    $("#txtInternalCompany").dropdown({
//        "delay": 100,
//        "gutter": 2,
//        "slidingIn": 100,
//        "stack": false
//    });

//    $('#txtOperatorName').dropdown({
//        "delay": 100,
//        "gutter": 2,
//        "slidingIn": 100,
//        "stack": false
//    });
//});

$(document).ready(function() {
    $("#tblItinerary").click(function(event) {
        console.log(event);

        event.stopPropagation();

        var target = $(event.target);

        if (target.closest("td").attr("colspan") > 1) {
            target.slideUp();
        } else {
            target.closest("tr").next().find("div").slideToggle();
        }
    });
});