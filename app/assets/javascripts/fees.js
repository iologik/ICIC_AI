
$(function() {
    // display total payment amount
    if($('.total_fee_amount').length > 0) {
        var total_fee_amount = $('.total_fee_amount.hide').text();
        $('#index_table_fees').find('tbody').append('<tr style="color:#000;"><td></td><td></td><td></td>' +
            '<td style="text-align:right;color:rgb(50, 53, 55);">Total:</td>' +
            '<td class="total-td">'+total_fee_amount+'</td>' +
            '</td><td></td><td></td><td></td><td></td><td></td></tr>');// todo note the first </td> which should be removed, also the code above
    }
});
