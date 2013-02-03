$(function() {
    var skipSort = [];

    $('table#users thead th').each(function() {
        if ($(this).text() == "") {
            skipSort.push({ "bSortable": false });
        } else {
            skipSort.push(null);
        }
    });

    $('table#users').dataTable({
        bPaginate: false,
        sDom: "<'top'i>flp",
        aoColumns: skipSort,
        asStripeClasses: []
    });
});
