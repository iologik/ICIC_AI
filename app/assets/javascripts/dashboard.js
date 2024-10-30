$(function () {
    if ($('body.index.admin_dashboard').length > 0) {

        function requestContent(columeName) {
            return function () {
                $.get('/admin/investments/dashboard_content', {column: columeName}, function (data) {
                    $('#column_' + data.column).html($(data.page));
                });
            }
        }

        var columns = ['first', 'second', 'third', 'fourth'];
        for (var i = 0; i < columns.length; i++) {
            var columeName = columns[i];
            setTimeout(requestContent(columeName), 500 * i);
        }
    }
})