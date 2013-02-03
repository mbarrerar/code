$(function() {
    var skipSort = [];

    $('table#spaces thead th').each(function() {
        if ($(this).text() == "") {
            skipSort.push({ "bSortable": false });
        } else {
            skipSort.push(null);
        }
    });

    $('table#spaces').dataTable({
        bPaginate: false,
        sDom: "<'top'i>flp",
        aoColumns: skipSort,
        asStripeClasses: []
    });
});
