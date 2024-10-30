$(function(){
    $(document).ready(function(){
        // investment accrued total
        if($('.investment-cad-accrued-total').length > 0) {
            var panel = $('.investment-cad-accrued-total').closest('.index_as_table');
            var cadAccrued = panel.find('.investment-cad-accrued-total').text();
            var usdAccrued = panel.find('.investment-usd-accrued-total').text();

            panel.find('tbody').append(`<tr style="color:#000;">
                <td style="text-align:right;color:rgb(50, 53, 55);">Total:</td>
                <td class="total-td">${cadAccrued}</td>
                <td class="total-td">${usdAccrued}</td>
                <td></td></tr>`);
        }
    });
})
