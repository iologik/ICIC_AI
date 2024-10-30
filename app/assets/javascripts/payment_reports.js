$(function(){
    $(document).ready(function(){
        // payment report total
        if($('.payment-report-total').length > 0) {
            var panel = $('.payment-report-total').closest('.index_as_table');
            var amountTotal = panel.find('.payment-report-total').text();

            panel.find('tbody').append(`<tr style="color:#000;">
                <td></td>
                <td style="text-align:right;color:rgb(50, 53, 55);">Total:</td>
                <td class="total-td">${amountTotal}</td>
                <td></td></tr>`);
        }
    })
})
