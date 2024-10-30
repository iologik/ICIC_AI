$(function() {
    // payment report total
    if($('.loan-payment-report-total').length > 0) {
        var panel = $('.loan-payment-report-total').closest('.index_as_table');
        var amountTotal = panel.find('.loan-payment-report-total').text();

        panel.find('tbody').append('<tr style="color:#000;">' +
            '<td></td><td></td><td></td>' +
            '<td style="text-align:right;color:rgb(50, 53, 55);">Total:</td>' +
            '<td class="total-td">' + amountTotal + '</td>' +
            '<td></td></tr>');
    }
})