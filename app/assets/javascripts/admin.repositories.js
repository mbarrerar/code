
$(function() {
    var dontSort = [];

    $('table#repositories thead th').each(function() {
        if ($(this).text() == "") {
            dontSort.push({ "bSortable": false });
        } else {
            dontSort.push(null);
        }
    });

    $('table#repositories').dataTable({
        bPaginate: false,
        sDom: "<'top'i>flp",
        aoColumns: dontSort,
        asStripeClasses: []
    });
});


var Admin = Admin || {};

Admin.Repositories = {
    init: function() {
        this.observeDiskUsage();
    },

    observeDiskUsage: function() {
        $("table#repositories tbody td.disk_usage img").toggle();
        $("table#repositories tbody td.disk_usage a").click(function(e) {
            e.preventDefault();

            var td = $(this).parent();
            td.children("img").toggle();
            td.children("span").text("");

            $.get(e.currentTarget.href, function(data) {
                td.children("span").text(data);
                td.children("img").toggle();
            });
        });
    }
};

Admin.Repositories.init();
